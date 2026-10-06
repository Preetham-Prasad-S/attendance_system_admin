// supabase/functions/create-institute-admin/index.ts
//
// Creates a pending (invited) admin account for an institute.
//
// Why this exists: a client app cannot create a row in `auth.users`. That
// needs the service_role key, which must never ship in a bundle
// (docs/backend/DECISIONS.md #5). So the app calls this function, which holds
// the key server-side.
//
// What it deliberately does NOT do:
//   - trust `organization` from the request body. The institute slug is
//     validated against the registry here, so the tenant stamp on the new
//     profile is server-decided. This keeps the client-metadata path in
//     `handle_new_user()` (migration 0001) unreachable for anyone but us.
//   - send email. Supabase's default mailer is rate-limited to a couple of
//     messages an hour, so instead the function returns a one-time setup link
//     that the super admin can pass on however they like.
//
// Deploy: supabase functions deploy create-institute-admin

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) return json({ error: 'Not signed in.' }, 401)

    // Service-role client: bypasses RLS, so it must only be used after the
    // caller has been authorised below.
    const admin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { autoRefreshToken: false, persistSession: false } },
    )

    // Authorisation from the database, not from anything in the request.
    // This is the single most security-critical check in the file.
    const token = authHeader.replace('Bearer ', '')
    const { data: userData, error: userError } = await admin.auth.getUser(token)
    if (userError || !userData.user) {
      return json({ error: 'Not signed in.' }, 401)
    }

    const { data: caller, error: profileError } = await admin
      .from('profiles')
      .select('role')
      .eq('id', userData.user.id)
      .maybeSingle()

    if (profileError) return json({ error: 'Could not verify your account.' }, 500)
    if (caller?.role !== 'super_admin') {
      return json({ error: 'Only a super admin can invite admins.' }, 403)
    }

    const body = await req.json().catch(() => null)
    const name = typeof body?.name === 'string' ? body.name.trim() : ''
    const email = typeof body?.email === 'string' ? body.email.trim() : ''
    const instituteSlug =
      typeof body?.institute_slug === 'string' ? body.institute_slug.trim() : ''

    if (name.length === 0) return json({ error: 'Enter their name.' }, 400)
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return json({ error: 'Enter a valid email address.' }, 400)
    }
    if (instituteSlug.length === 0) {
      return json({ error: 'Choose an institute for this admin.' }, 400)
    }

    const { data: institute, error: instituteError } = await admin
      .from('institutes')
      .select('slug, name, is_active')
      .eq('slug', instituteSlug)
      .maybeSingle()

    if (instituteError) {
      return json({ error: 'Could not look up that institute.' }, 500)
    }
    if (!institute) return json({ error: 'That institute does not exist.' }, 400)
    if (!institute.is_active) {
      return json({ error: 'That institute is deactivated.' }, 400)
    }

    const { data: created, error: createError } = await admin.auth.admin.createUser(
      {
        email,
        // Unconfirmed: the invitee has no password yet. Migration 0008 leaves
        // the profile 'invited', which routes them to the setup screen.
        email_confirm: false,
        user_metadata: {
          name,
          organization: institute.slug,
          invited_by: userData.user.id,
        },
      },
    )

    if (createError) {
      const message = createError.message ?? ''
      if (
        message.toLowerCase().includes('already') &&
        message.toLowerCase().includes('registered')
      ) {
        return json(
          { error: 'An account with this email already exists.' },
          409,
        )
      }
      return json({ error: 'Could not create the account. Please try again.' }, 500)
    }

    // handle_new_user() copies organization from user_metadata into the
    // profile. Stamp who invited them, too.
    await admin
      .from('profiles')
      .update({ invited_by: userData.user.id, status: 'invited' })
      .eq('id', created.user.id)

    // A one-time link the super admin can share directly. Not emailed: the
    // default Supabase mailer is rate-limited.
    const { data: linkData, error: linkError } = await admin.auth.admin
      .generateLink({ type: 'recovery', email })

    return json({
      profile_id: created.user.id,
      institute: institute.name,
      // Null when generation fails — the admin still exists and can use the
      // "forgot password" route on the login screen.
      setup_link: linkError ? null : linkData?.properties?.action_link ?? null,
    })
  } catch (error) {
    console.error('create-institute-admin failed', error)
    return json({ error: 'Something went wrong. Please try again.' }, 500)
  }
})