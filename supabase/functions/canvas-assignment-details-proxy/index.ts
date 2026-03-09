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

async function requireAuthenticatedUser(req: Request): Promise<void> {
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
}

deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    console.log("=== Canvas Assignment Details Proxy Request ===");
    console.log("Method:", req.method);
    console.log("URL:", req.url);

    const authHeader = req.headers.get("authorization");
    console.log("Authorization header present:", !!authHeader);
    await requireAuthenticatedUser(req);

    // ✅ ดึง assignment_id และ course_id จาก URL
    const url = new URL(req.url);
    const assignmentId = url.searchParams.get("assignment_id");
    const courseId = url.searchParams.get("course_id");

    if (!assignmentId || !courseId) {
      console.error("Missing required parameters: assignment_id or course_id");
      return new Response(
        JSON.stringify({
          error: "Missing required parameters: assignment_id and course_id",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    console.log(
      `✅ Fetching assignment details for assignment_id=${assignmentId}, course_id=${courseId}`,
    );

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

    // ✅ เรียก Canvas API - Assignment Details
    const assignmentDetailsUrl = new URL(
      `${canvasBaseUrl}/api/v1/courses/${courseId}/assignments/${assignmentId}`,
    );

    console.log(
      "Fetching Canvas assignment details from:",
      assignmentDetailsUrl.toString(),
    );

    const canvasRes = await fetch(assignmentDetailsUrl.toString(), {
      headers: {
        Authorization: `Bearer ${canvasToken}`,
        "Content-Type": "application/json",
      },
    });

    console.log("Canvas API response status:", canvasRes.status);

    if (canvasRes.status >= 400) {
      const errorText = await canvasRes.text();
      console.error("Canvas API error:", errorText);
      return new Response(JSON.stringify({ error: errorText }), {
        status: canvasRes.status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const rawData = await canvasRes.json();

    console.log("Canvas assignment details received:", {
      id: rawData.id,
      name: rawData.name,
      hasDescription: !!rawData.description,
      hasPoints: !!rawData.points_possible,
      hasRubric: !!rawData.rubric,
    });

    const response = {
      id: rawData.id,
      name: rawData.name || "",
      description: rawData.description || "",
      full_description: rawData.description || "",
      points_possible: rawData.points_possible || null,
      submission_types: rawData.submission_types || [],
      rubric: rawData.rubric || null,
      due_at: rawData.due_at || null,
      course_id: parseInt(courseId),
    };

    console.log("✅ Returning assignment details");
    console.log("==================================================");

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

    console.error("=== ERROR in canvas-assignment-details-proxy ===");
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
