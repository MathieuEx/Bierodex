// Suppression définitive du compte de l'utilisateur qui appelle la fonction
// (bouton "Supprimer mon compte", lib/screens/account_screen.dart).
//
// Supprimer un utilisateur d'Auth exige la clé service_role : c'est pour
// ça que ce code tourne ici, côté serveur, et jamais dans l'app. La clé est
// fournie automatiquement par Supabase aux Edge Functions
// (SUPABASE_SERVICE_ROLE_KEY) : rien à configurer, rien à committer.
//
// Déploiement : `supabase functions deploy delete-account`
// (la vérification du JWT par la passerelle reste activée par défaut).

import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json(405, { error: "method_not_allowed" });

  const authorization = req.headers.get("Authorization") ?? "";
  if (!authorization.startsWith("Bearer ")) return json(401, { error: "unauthorized" });

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  // L'identité vient uniquement du jeton, jamais du corps de la requête :
  // impossible de demander la suppression du compte de quelqu'un d'autre.
  const { data, error } = await admin.auth.getUser(authorization.slice("Bearer ".length));
  const user = data?.user;
  if (error || !user) return json(401, { error: "unauthorized" });

  // Suppression explicite plutôt que de compter sur `on delete cascade` :
  // beer_status a été créée à la main et sa clé étrangère n'est pas garantie.
  for (const table of ["beer_status", "user_beers"]) {
    const { error: deleteError } = await admin.from(table).delete().eq("user_id", user.id);
    if (deleteError) {
      console.error(`delete-account: ${table}`, deleteError.message);
      return json(500, { error: "delete_failed" });
    }
  }

  const { error: userError } = await admin.auth.admin.deleteUser(user.id);
  if (userError) {
    console.error("delete-account: auth user", userError.message);
    return json(500, { error: "delete_failed" });
  }

  return json(200, { deleted: true });
});
