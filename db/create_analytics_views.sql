-- Create analytics Postgres schema & create views
-- so it can be used to query non-sensitive data about
-- the production database.
--
-- Specifically avoid credentials (passwords, auth tokens),
-- personally identifying information (email addresses, phone numbers, IP addresses),
-- and free text fields (document names, freeform intake questions)
-- since they often contain some of the above.
--
-- VIEWs in this file are listed alphabetically, like tables in schema.db.
--
-- We use CREATE OR REPLACE VIEW to avoid dropping and re-generating views every time.
-- If you need to drop these views for some reason, it's OK. Do so with with:
-- `rails analytics:remove` or DROP SCHEMA IF EXISTS analytics CASCADE;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE OR REPLACE VIEW analytics.access_logs AS
    SELECT id, client_id, created_at, event_type, updated_at, user_id, user_agent FROM public.access_logs;

CREATE OR REPLACE VIEW analytics.active_storage_attachments AS
    SELECT id, blob_id, created_at, record_id, record_type FROM public.active_storage_attachments;

CREATE OR REPLACE VIEW analytics.active_storage_blobs AS
    SELECT id, byte_size, checksum, content_type, created_at, key FROM public.active_storage_blobs;

CREATE OR REPLACE VIEW analytics.admin_roles AS
    SELECT id, created_at, updated_at FROM public.admin_roles;

-- TODO: anonymized_diy_intake_csv_extracts
-- TODO: anonymized_intake_csv_extracts
-- TODO: client_success_roles
-- TODO: clients
-- TODO: coalition_lead_roles
-- TODO: coalitions
-- TODO: delayed_jobs
-- TODO: dependents
-- TODO: diy_intakes
-- TODO: documents
-- TODO: documents_requests
-- TODO: greeter_coalition_join_records
-- TODO: greeter_organization_join_records
-- TODO: greeter_roles
-- TODO: incoming_emails
-- TODO: incoming_text_messages
-- TODO: intakes
CREATE OR REPLACE VIEW analytics.intakes as
    SELECT id from intakes;
-- TODO: notes
-- TODO: organization_lead_roles
-- TODO: outbound_calls
-- TODO: outgoing_emails
-- TODO: outgoing_text_messages
-- TODO: provider_scrapes
-- TODO: signups
-- TODO: site_coordinator_roles
-- TODO: source_parameters
-- TODO: stimulus_triages
-- TODO: system_notes
-- TODO: tax_returns
-- TODO: team_member_roles
-- TODO: users
-- TODO: vita_partner_states
-- TODO: vita_partner_zip_codes
-- TODO: vita_partners
-- TODO: vita_providers
