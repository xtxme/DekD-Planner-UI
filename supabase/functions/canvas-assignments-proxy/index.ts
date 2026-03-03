import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

type DenoLike = {
  serve: (handler: (req: Request) => Response | Promise<Response>) => void;
  env: {
    get: (key: string) => string | undefined;
  };
};

const deno = (globalThis as unknown as { Deno: DenoLike }).Deno;

function mapTodoItem(item: Record<string, unknown>) {
  const assignment = item.assignment;
  const course = item.course;

  const assignmentMap =
    assignment && typeof assignment === "object"
      ? assignment as Record<string, unknown>
      : {};

  const courseMap =
    course && typeof course === "object"
      ? course as Record<string, unknown>
      : {};

  return {
    id: typeof assignmentMap.id === "number" ? assignmentMap.id : 0,
    name: typeof assignmentMap.name === "string" ? assignmentMap.name : "",
    due_at: typeof assignmentMap.due_at === "string" ? assignmentMap.due_at : null,
    course_id: typeof courseMap.id === "number" ? courseMap.id : null,
    course_name: typeof courseMap.name === "string" ? courseMap.name : "",
    description:
      typeof assignmentMap.description === "string" ? assignmentMap.description : "",
  };
}

deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const canvasBaseUrl = deno.env.get("CANVAS_BASE_URL");
    const canvasToken = deno.env.get("CANVAS_TOKEN");

    if (!canvasBaseUrl || !canvasToken) {
      return new Response(
        JSON.stringify({ error: "Missing CANVAS_BASE_URL or CANVAS_TOKEN" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const assignmentsUrl = new URL(`${canvasBaseUrl}/api/v1/users/self/todo`);
    assignmentsUrl.searchParams.set("per_page", "100");

    const canvasRes = await fetch(assignmentsUrl, {
      headers: {
        Authorization: `Bearer ${canvasToken}`,
        "Content-Type": "application/json",
      },
    });

    const rawData = await canvasRes.json();

    if (canvasRes.status >= 400) {
      return new Response(JSON.stringify(rawData), {
        status: canvasRes.status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!Array.isArray(rawData)) {
      throw new Error("Canvas assignments response is not an array");
    }

    const normalized = rawData
      .filter((item) => item && typeof item === "object")
      .map((item) => mapTodoItem(item as Record<string, unknown>))
      .filter((item) => item.id !== 0 && item.name.trim().length > 0);

    return new Response(JSON.stringify(normalized), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
