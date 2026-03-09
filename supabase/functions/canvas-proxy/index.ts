// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
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
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    await requireAuthenticatedUser(req);

    const canvasBaseUrl = deno.env.get("CANVAS_BASE_URL");
    const canvasToken = deno.env.get("CANVAS_TOKEN");

    if (!canvasBaseUrl || !canvasToken) {
      return new Response(
        JSON.stringify({ error: "Missing CANVAS_BASE_URL or CANVAS_TOKEN" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const coursesUrl = new URL(`${canvasBaseUrl}/api/v1/courses`);
    coursesUrl.searchParams.set("per_page", "100");
    coursesUrl.searchParams.append("include[]", "teachers");

    const canvasRes = await fetch(coursesUrl, {
      headers: {
        Authorization: `Bearer ${canvasToken}`,
        "Content-Type": "application/json",
      },
    });

    const text = await canvasRes.text();
    return new Response(text, {
      status: canvasRes.status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
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

    return new Response(
      JSON.stringify({ error: String(e) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/canvas-proxy' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
