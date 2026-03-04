import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
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

// ✅ Decode JWT payload using Deno-compatible base64 decoding
function decodeJwtPayload(token: string) {
  try {
    const parts = token.split('.');
    if (parts.length < 2) {
      console.error('Invalid JWT format: not enough parts');
      return null;
    }

    // ✅ Use Deno's base64 decoding
    const base64Url = parts[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    
    // ✅ Decode base64 using Deno's built-in
    const binaryString = atob(base64);
    const bytes = new Uint8Array(binaryString.length);
    for (let i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    
    // ✅ Convert bytes to string
    const decoder = new TextDecoder();
    const jsonString = decoder.decode(bytes);
    
    // ✅ Parse JSON
    const payload = JSON.parse(jsonString);
    
    console.log('JWT payload decoded successfully:', {
      sub: payload.sub,
      email: payload.email,
      exp: payload.exp
    });
    
    return payload;
  } catch (e) {
    console.error('Error decoding JWT:', e);
    return null;
  }
}

deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    console.log('=== Canvas Assignments Proxy Request ===');
    console.log('Method:', req.method);
    console.log('URL:', req.url);

    // ✅ ตรวจสอบ authorization header
    const authHeader = req.headers.get('authorization');
    console.log('Authorization header present:', !!authHeader);

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      console.error('Missing or invalid authorization header');
      return new Response(
        JSON.stringify({ error: "Missing or invalid authorization header" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // ✅ Extract token จาก Authorization header
    const token = authHeader.replace('Bearer ', '');
    console.log('Token received (first 50 chars):', token.substring(0, 50) + '...');

    // ✅ Decode JWT payload โดยตรง
    const payload = decodeJwtPayload(token);

    if (!payload || !payload.sub) {
      console.error('Invalid JWT payload - no sub field');
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // ✅ ดึง user info จาก JWT payload
    const userId = payload.sub;
    const userEmail = payload.email || 'unknown@example.com';
    
    console.log(`✅ User authenticated: ${userEmail} (ID: ${userId})`);

    // ✅ ตรวจสอบ Canvas credentials
    const canvasBaseUrl = deno.env.get("CANVAS_BASE_URL");
    const canvasToken = deno.env.get("CANVAS_TOKEN");

    if (!canvasBaseUrl || !canvasToken) {
      console.error('Missing Canvas credentials');
      return new Response(
        JSON.stringify({ error: "Missing CANVAS_BASE_URL or CANVAS_TOKEN" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log('Canvas Base URL:', canvasBaseUrl);

    // ✅ เรียก Canvas API
    const assignmentsUrl = new URL(`${canvasBaseUrl}/api/v1/users/self/todo`);
    assignmentsUrl.searchParams.set("per_page", "100");

    console.log('Fetching Canvas assignments from:', assignmentsUrl.toString());

    const canvasRes = await fetch(assignmentsUrl, {
      headers: {
        Authorization: `Bearer ${canvasToken}`,
        "Content-Type": "application/json",
      },
    });

    console.log('Canvas API response status:', canvasRes.status);

    const rawData = await canvasRes.json();

    if (canvasRes.status >= 400) {
      console.error('Canvas API error:', rawData);
      return new Response(JSON.stringify(rawData), {
        status: canvasRes.status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!Array.isArray(rawData)) {
      console.error('Canvas response is not an array:', typeof rawData);
      throw new Error("Canvas assignments response is not an array");
    }

    console.log('Canvas assignments received:', rawData.length);

    const normalized = rawData
      .filter((item) => item && typeof item === "object")
      .map((item) => mapTodoItem(item as Record<string, unknown>))
      .filter((item) => item.id !== 0 && item.name.trim().length > 0);

    console.log('Normalized assignments:', normalized.length);

    const response = {
      user: {
        id: userId,
        email: userEmail,
      },
      assignments: normalized,
    };

    console.log('✅ Returning response with', normalized.length, 'assignments');

    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (e) {
    console.error('=== ERROR in canvas-assignments-proxy ===');
    console.error('Error:', e);
    return new Response(
      JSON.stringify({ error: String(e) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
