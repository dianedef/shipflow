# Supabase Storage Reference

Use this reference when the task involves uploads, downloads, signed URLs, private/public buckets, or file access control in Supabase Storage.

Sources checked:
- https://supabase.com/docs/guides/storage
- https://supabase.com/docs/guides/storage/buckets/fundamentals
- https://supabase.com/docs/guides/storage/management/download-objects
- https://supabase.com/docs/reference/javascript/storage-from-createsignedurl
- https://supabase.com/docs/reference/javascript/storage-from-createsigneduploadurl
- https://supabase.com/docs/reference/csharp/storage-from-upload

Last reviewed: 2026-04-26

## When To Load This

- User uploads or downloads files through Supabase.
- A feature needs public assets, private assets, or time-limited sharing.
- An upload works locally but fails in preview or production.
- Access to files depends on user, org, or project ownership.
- The design of a new feature depends on bucket policy, path strategy, or signed URLs.

## Core Rules

- Buckets are private by default.
- Public buckets bypass access control for file retrieval, but mutating operations still rely on access control.
- Private bucket access is typically enforced through RLS on `storage.objects`.
- Private downloads need either an authenticated request with the user's JWT or a signed URL.
- Signed URLs are for time-limited sharing. Signed upload URLs allow upload without further auth for a limited window.
- Large or unreliable uploads should consider the resumable/TUS path instead of naive single-request uploads.
- File metadata lives in Postgres tables such as `storage.buckets` and `storage.objects`, so storage behavior and DB policy design are coupled.

## Security Rules

- Never put `SUPABASE_SERVICE_ROLE_KEY` in client code to bypass storage policies.
- Do not assume a hidden file path is access control. The bucket mode and `storage.objects` policies are the control plane.
- Namespace object paths by tenant/user/project when access is scoped that way. Flat shared paths create easy cross-tenant mistakes.
- Public buckets are suitable only when the product truly allows anyone with the URL to read the asset.

## What To Inspect

- Bucket type: public or private
- Upload restrictions: allowed MIME types, max size, and bucket-level settings
- Policies on `storage.objects`
- Whether the app uses user JWT, signed URL, or admin/server path
- Object path conventions and ownership mapping
- Any linked application table that tracks file metadata or ownership

## Common Failure Modes

- The code assumes a bucket is public, but it is private.
- The bucket is public, but the app expects retrieval to be permissioned.
- Upload path is not scoped by tenant/user, so users overwrite or read each other's files.
- `insert` policy exists but `select`, `update`, or `delete` policy is missing.
- Client code attempts to bypass policy failures with the service role key.
- Signed URL expires too quickly or is generated for the wrong path.
- Large uploads fail because the implementation needs resumable upload support.
- Metadata row is created in app tables but the storage upload fails, or the reverse, leaving inconsistent state.

## Pattern Guidance

- Public avatars or marketing assets: public bucket only if true public read is acceptable.
- Sensitive user documents: private bucket plus ownership-aware `storage.objects` policies.
- Server-generated exports: generate server-side and return a signed URL or controlled download path.
- Multi-tenant apps: keep bucket naming simple, but encode tenant/resource ownership clearly in object paths and matching policies.

## Default Checklist

1. Confirm whether the asset should be public, private, or temporarily shareable.
2. Confirm the bucket mode and restrictions.
3. Inspect `storage.objects` policies for each needed operation.
4. Verify the path scheme matches the ownership model.
5. Verify the client/server key choice is correct.
6. If metadata or business records are coupled to the file, cross-check `/home/claude/shipflow/skills/references/supabase-db.md`.
