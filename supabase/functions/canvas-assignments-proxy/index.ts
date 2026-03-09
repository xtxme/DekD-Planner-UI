import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

type DenoLike = {
  serve: (handler: (req: Request) => Response | Promise<Response>) => void;
  env: {
    get: (key: string) => string | undefined;
  };
};

const deno = (globalThis as unknown as { Deno: DenoLike }).Deno;

class AuthValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "AuthValidationError";
  }
}

function toNumber(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string" && value.trim().length > 0) {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }
  return null;
}

function toText(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function toBoolean(value: unknown): boolean | null {
  if (typeof value === "boolean") {
    return value;
  }

  if (typeof value === "number") {
    if (value === 1) return true;
    if (value === 0) return false;
  }

  if (typeof value === "string") {
    const normalized = value.trim().toLowerCase();
    if (normalized === "true" || normalized === "1") return true;
    if (normalized === "false" || normalized === "0") return false;
  }

  return null;
}

function extractCourseIdFromUrl(value: unknown): number | null {
  if (typeof value !== "string" || value.trim().length === 0) {
    return null;
  }

  const match = /\/courses\/(\d+)(?:\/|$)/i.exec(value);
  if (!match) {
    return null;
  }
  return Number(match[1]);
}

function extractCourseIdFromContextCode(value: unknown): number | null {
  if (typeof value !== "string" || value.trim().length === 0) {
    return null;
  }

  const match = /course[_-](\d+)/i.exec(value);
  if (!match) {
    return null;
  }
  return Number(match[1]);
}

function mapTodoItem(item: Record<string, unknown>) {
  const assignment = item.assignment;
  const course = item.course;
  const submission = item.submission;

  const assignmentMap = assignment && typeof assignment === "object"
    ? assignment as Record<string, unknown>
    : {};

  const courseMap = course && typeof course === "object"
    ? course as Record<string, unknown>
    : {};

  const submissionMap = submission && typeof submission === "object"
    ? submission as Record<string, unknown>
    : {};

  const resolvedCourseId = toNumber(courseMap.id) ??
    toNumber(courseMap.course_id) ??
    toNumber(assignmentMap.course_id) ??
    toNumber(assignmentMap.courseId) ??
    toNumber(item.course_id) ??
    toNumber(item.courseId) ??
    toNumber(item.context_id) ??
    toNumber(item.contextId) ??
    extractCourseIdFromContextCode(item.context_code) ??
    extractCourseIdFromContextCode(item.contextCode) ??
    extractCourseIdFromUrl(assignmentMap.html_url) ??
    extractCourseIdFromUrl(item.assignment_url) ??
    extractCourseIdFromUrl(item.html_url);

  const courseNameCandidates = [
    courseMap.name,
    courseMap.course_name,
    item.course_name,
    item.courseName,
    item.context_name,
    item.contextName,
    assignmentMap.course_name,
    assignmentMap.courseName,
  ];

  const courseName = courseNameCandidates
    .map((value) => toText(value))
    .find((value) => value.length > 0) ?? "";

  const submissionStateCandidates = [
    submissionMap.workflow_state,
    submissionMap.workflowState,
    assignmentMap.submission_state,
    assignmentMap.submissionState,
    assignmentMap.workflow_state,
    assignmentMap.workflowState,
    item.submission_state,
    item.submissionState,
    item.workflow_state,
    item.workflowState,
  ];

  const submissionState = submissionStateCandidates
    .map((value) => toText(value).toLowerCase())
    .find((value) => value.length > 0) ?? "";

  const completionSignal = toBoolean(item.is_completed) ??
    toBoolean(item.isCompleted) ??
    toBoolean(item.completed) ??
    toBoolean(assignmentMap.is_completed) ??
    toBoolean(assignmentMap.isCompleted) ??
    toBoolean(assignmentMap.completed) ??
    toBoolean(assignmentMap.has_submitted_submissions) ??
    false;

  const isCompletedFromState = submissionState === "graded" ||
    submissionState === "submitted" ||
    submissionState === "complete" ||
    submissionState === "completed";

  const isCompleted = completionSignal || isCompletedFromState;

  return {
    id: typeof assignmentMap.id === "number" ? assignmentMap.id : 0,
    name: typeof assignmentMap.name === "string" ? assignmentMap.name : "",
    due_at: typeof assignmentMap.due_at === "string"
      ? assignmentMap.due_at
      : null,
    course_id: resolvedCourseId,
    course_name: courseName,
    description: typeof assignmentMap.description === "string"
      ? assignmentMap.description
      : "",
    is_completed: isCompleted,
    submission_state: submissionState,
  };
}

async function requireAuthenticatedUser(
  req: Request,
): Promise<{ id: string; email: string }> {
  const authHeader = req.headers.get("authorization");
  const apikey = req.headers.get("apikey");

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new AuthValidationError("Missing or invalid authorization header");
  }
  if (!apikey || apikey.trim().length === 0) {
    throw new AuthValidationError("Missing apikey header");
  }

  const origin = new URL(req.url).origin;
  const authUrl = new URL("/auth/v1/user", origin);
  const authRes = await fetch(authUrl.toString(), {
    headers: {
      Authorization: authHeader,
      apikey,
    },
  });

  if (authRes.status >= 400) {
    const errorText = await authRes.text();
    console.error("Auth validation failed:", authRes.status, errorText);
    throw new AuthValidationError("Invalid JWT");
  }

  const user = await authRes.json();
  const userId = typeof user?.id === "string" ? user.id : "";
  const userEmail = typeof user?.email === "string"
    ? user.email
    : "unknown@example.com";

  if (userId.trim().length === 0) {
    throw new AuthValidationError("Invalid JWT");
  }

  return { id: userId, email: userEmail };
}

deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    console.log("=== Canvas Assignments Proxy Request ===");
    console.log("Method:", req.method);
    console.log("URL:", req.url);

    const authHeader = req.headers.get("authorization");
    console.log("Authorization header present:", !!authHeader);

    const user = await requireAuthenticatedUser(req);
    const userId = user.id;
    const userEmail = user.email;

    console.log(`✅ User authenticated: ${userEmail} (ID: ${userId})`);

    // ✅ ตรวจสอบ Canvas credentials
    const canvasBaseUrl = deno.env.get("CANVAS_BASE_URL");
    const canvasToken = deno.env.get("CANVAS_TOKEN");

    if (!canvasBaseUrl || !canvasToken) {
      console.error("Missing Canvas credentials");
      return new Response(
        JSON.stringify({ error: "Missing CANVAS_BASE_URL or CANVAS_TOKEN" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    console.log("Canvas Base URL:", canvasBaseUrl);

    // ✅ เรียก Canvas API
    const assignmentsUrl = new URL(`${canvasBaseUrl}/api/v1/users/self/todo`);
    assignmentsUrl.searchParams.set("per_page", "100");

    console.log("Fetching Canvas assignments from:", assignmentsUrl.toString());

    const canvasRes = await fetch(assignmentsUrl, {
      headers: {
        Authorization: `Bearer ${canvasToken}`,
        "Content-Type": "application/json",
      },
    });

    console.log("Canvas API response status:", canvasRes.status);

    const rawData = await canvasRes.json();

    if (canvasRes.status >= 400) {
      console.error("Canvas API error:", rawData);
      return new Response(JSON.stringify(rawData), {
        status: canvasRes.status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!Array.isArray(rawData)) {
      console.error("Canvas response is not an array:", typeof rawData);
      throw new Error("Canvas assignments response is not an array");
    }

    console.log("Canvas assignments received:", rawData.length);

    const normalized = rawData
      .filter((item) => item && typeof item === "object")
      .map((item) => mapTodoItem(item as Record<string, unknown>))
      .filter((item) => item.id !== 0 && item.name.trim().length > 0);

    console.log("Normalized assignments:", normalized.length);

    const response = {
      user: {
        id: userId,
        email: userEmail,
      },
      assignments: normalized,
    };

    console.log("✅ Returning response with", normalized.length, "assignments");

    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (e) {
    if (e instanceof AuthValidationError) {
      return new Response(
        JSON.stringify({ code: 401, message: "Invalid JWT" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    console.error("=== ERROR in canvas-assignments-proxy ===");
    console.error("Error:", e);
    return new Response(
      JSON.stringify({ error: String(e) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
