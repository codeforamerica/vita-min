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
-- We drop the schema to avoid CREATE OR REPLACE failing if column order changes
DROP SCHEMA IF EXISTS analytics CASCADE;
CREATE SCHEMA analytics;

CREATE VIEW analytics.accepted_tax_return_analytics AS
    SELECT *
    FROM public.accepted_tax_return_analytics;

CREATE VIEW analytics.active_storage_attachments AS
    SELECT id, blob_id, created_at, record_id, record_type
    FROM public.active_storage_attachments;

CREATE VIEW analytics.active_storage_blobs AS
    SELECT id, byte_size, checksum, content_type, created_at, key
    FROM public.active_storage_blobs;

CREATE VIEW analytics.admin_roles AS
    SELECT id, created_at, updated_at
    FROM public.admin_roles;

CREATE VIEW analytics.anonymized_diy_intake_csv_extracts AS
    SELECT id, created_at, record_count, run_at, updated_at
    FROM public.anonymized_diy_intake_csv_extracts;

CREATE VIEW analytics.anonymized_intake_csv_extracts AS
    SELECT id, created_at, record_count, run_at, updated_at
    FROM public.anonymized_intake_csv_extracts;

CREATE VIEW analytics.client_success_roles AS
    SELECT id, created_at, updated_at
    FROM public.client_success_roles;

CREATE VIEW analytics.clients AS
    SELECT id, attention_needed_since, created_at, current_sign_in_at, failed_attempts, first_unanswered_incoming_interaction_at, flagged_at, last_incoming_interaction_at, last_internal_or_outgoing_interaction_at, last_sign_in_at, locked_at, login_requested_at, routing_method, sign_in_count, updated_at, vita_partner_id
    FROM public.clients;

CREATE VIEW analytics.coalition_lead_roles AS
    SELECT id, coalition_id, created_at, updated_at
    FROM public.coalition_lead_roles;

CREATE VIEW analytics.coalitions AS
    SELECT id, created_at, name, updated_at
    FROM public.coalitions;

CREATE VIEW analytics.delayed_jobs AS
    SELECT id, attempts, created_at, failed_at, locked_at, locked_by, priority, queue, run_at, updated_at
    FROM public.delayed_jobs;

CREATE VIEW analytics.dependents AS
    SELECT id, created_at, disabled, intake_id, months_in_home, north_american_resident, on_visa, tin_type, updated_at, was_married, was_student
    FROM public.dependents;

CREATE VIEW analytics.diy_intakes AS
    SELECT id, created_at, locale, referrer, source, updated_at, visitor_id, zip_code
    FROM public.diy_intakes;

CREATE VIEW analytics.documents AS
    SELECT id, client_id, contact_record_id, contact_record_type, created_at, document_type, documents_request_id, intake_id, tax_return_id, updated_at, uploaded_by_id, uploaded_by_type
    FROM public.documents;

CREATE VIEW analytics.documents_requests AS
    SELECT id, created_at, intake_id, updated_at
    FROM public.documents_requests;

CREATE VIEW analytics.efile_errors AS
    SELECT id, auto_cancel, auto_wait, category, code, created_at, expose, message, severity, source, updated_at
    FROM public.efile_errors;

CREATE VIEW analytics.efile_submission_transition_errors AS
    SELECT id, created_at, efile_error_id, efile_submission_id, efile_submission_transition_id, updated_at
    FROM public.efile_submission_transition_errors;

CREATE VIEW analytics.efile_submission_transitions AS
    SELECT id, created_at, efile_submission_id, most_recent, sort_key, to_state, updated_at
    FROM public.efile_submission_transitions;

CREATE VIEW analytics.efile_submissions AS
    SELECT id, created_at, irs_submission_id, tax_return_id, updated_at
    FROM public.efile_submissions;

CREATE VIEW analytics.greeter_coalition_join_records AS
    SELECT id, coalition_id, created_at, greeter_role_id, updated_at
    FROM public.greeter_coalition_join_records;

CREATE VIEW analytics.greeter_organization_join_records AS
    SELECT id, greeter_role_id, updated_at, vita_partner_id
    FROM public.greeter_organization_join_records;

CREATE VIEW analytics.greeter_roles AS
    SELECT id, created_at, updated_at
    FROM public.greeter_roles;

CREATE VIEW analytics.incoming_emails AS
    SELECT id, attachment_count, client_id, created_at, received_at, updated_at
    FROM public.incoming_emails;

CREATE VIEW analytics.intakes AS
    SELECT id, adopted_child, already_applied_for_stimulus, already_filed, balance_pay_from_bank,
           bank_account_type, bought_energy_efficient_items, bought_health_insurance, city,
           claimed_by_another, client_id, completed_at, completed_yes_no_questions_at, continued_at_capacity,
           created_at, demographic_disability, demographic_english_conversation, demographic_english_reading,
           demographic_primary_american_indian_alaska_native, demographic_primary_asian,
           demographic_primary_black_african_american, demographic_primary_ethnicity,
           demographic_primary_native_hawaiian_pacific_islander, demographic_primary_prefer_not_to_answer_race,
           demographic_primary_white, demographic_questions_opt_in, demographic_spouse_american_indian_alaska_native,
           demographic_spouse_asian, demographic_spouse_black_african_american, demographic_spouse_ethnicity,
           demographic_spouse_native_hawaiian_pacific_islander, demographic_spouse_prefer_not_to_answer_race,
           demographic_spouse_white, demographic_veteran, divorced, divorced_year, eip_only,
           email_notification_opt_in, ever_married, feeling_about_taxes, filing_for_stimulus, filing_joint,
           had_asset_sale_income, had_debt_forgiven, had_dependents, had_disability, had_disability_income,
           had_disaster_loss, had_farm_income, had_gambling_income, had_hsa, had_interest_income,
           had_local_tax_refund, had_other_income, had_rental_income, had_retirement_income,
           had_self_employment_income, had_social_security_income, had_social_security_or_retirement,
           had_student_in_family, had_tax_credit_disallowed, had_tips, had_unemployment_income, had_wages,
           income_over_limit, issued_identity_pin, job_count, lived_with_spouse, locale,
           made_estimated_tax_payments, married, multiple_states, needs_help_2016, needs_help_2017, needs_help_2018,
           needs_help_2019, needs_help_2020, no_eligibility_checks_apply, no_ssn, paid_alimony,
           paid_charitable_contributions, paid_dependent_care, paid_local_tax, paid_medical_expenses,
           paid_mortgage_interest, paid_retirement_contributions, paid_school_supplies, paid_student_loan_interest,
           phone_number_can_receive_texts, preferred_interview_language, primary_consented_to_service, primary_consented_to_service_at, primary_tin_type,
           received_alimony, received_irs_letter, refund_payment_method, reported_asset_sale_loss,
           reported_self_employment_loss, satisfaction_face,
           savings_purchase_bond, savings_split_refund, separated, separated_year, signature_method,
           sms_notification_opt_in, sold_a_home, sold_assets, source, spouse_consented_to_service,
           spouse_consented_to_service_at, spouse_had_disability, spouse_issued_identity_pin, spouse_tin_type, spouse_was_blind,
           spouse_was_full_time_student, spouse_was_on_visa, state, state_of_residence,
           updated_at, viewed_at_capacity, visitor_id, vita_partner_id, was_blind, was_full_time_student,
           was_on_visa, widowed, type, zip_code
    FROM public.intakes;

CREATE VIEW analytics.notes AS
    SELECT id, client_id, created_at, updated_at, user_id
    FROM public.notes;

CREATE VIEW analytics.organization_lead_roles AS
    SELECT id, created_at, updated_at, vita_partner_id
    FROM public.organization_lead_roles;

CREATE VIEW analytics.outbound_calls AS
    SELECT id, client_id, created_at, twilio_call_duration, twilio_sid, twilio_status, updated_at, user_id
    FROM public.outbound_calls;

CREATE VIEW analytics.outgoing_emails AS
    SELECT id, client_id, created_at, mailgun_status, message_id, sent_at, updated_at, user_id
    FROM public.outgoing_emails;

CREATE VIEW analytics.outgoing_text_messages AS
    SELECT id, body, client_id, created_at, sent_at, twilio_sid, twilio_status, updated_at, user_id
    FROM public.outgoing_text_messages;

CREATE VIEW analytics.provider_scrapes AS
    SELECT id, archived_count, changed_count, created_at, created_count, updated_at
    FROM public.provider_scrapes;

CREATE VIEW analytics.signups AS
    SELECT id, created_at, updated_at
    FROM public.signups;

CREATE VIEW analytics.site_coordinator_roles AS
    SELECT id, created_at, updated_at, vita_partner_id
    FROM public.site_coordinator_roles;

CREATE VIEW analytics.source_parameters AS
    SELECT id, code, created_at, updated_at, vita_partner_id
    FROM public.source_parameters;

CREATE VIEW analytics.system_notes AS
    SELECT id, client_id, created_at, type, updated_at, user_id
    FROM public.system_notes;

CREATE VIEW analytics.tax_returns AS
    SELECT id, assigned_user_id, certification_level, client_id, created_at, is_hsa,
           primary_signature, primary_signed_at, ready_for_prep_at, service_type, spouse_signature, spouse_signed_at,
           status, updated_at, year, is_ctc
    FROM public.tax_returns;

CREATE VIEW analytics.team_member_roles AS
    SELECT id, created_at, updated_at, vita_partner_id
    FROM public.team_member_roles;

CREATE VIEW analytics.users AS
    SELECT id, created_at, current_sign_in_at, failed_attempts, invitation_accepted_at, invitation_created_at,
           invitation_limit, invitation_sent_at, invitations_count, invited_by_id, last_sign_in_at,
           locked_at, reset_password_sent_at, role_id, role_type, sign_in_count, suspended_at, timezone, updated_at
    FROM public.users;

CREATE VIEW analytics.state_routing_targets AS
    SELECT id, created_at, routing_fraction, state, updated_at, vita_partner_id
    FROM public.state_routing_targets;

CREATE VIEW analytics.vita_partner_zip_codes AS
    SELECT id, created_at, updated_at, vita_partner_id, zip_code
    FROM public.vita_partner_zip_codes;

CREATE VIEW analytics.vita_partners AS
    SELECT id, archived, capacity_limit, coalition_id, created_at, logo_path, name, national_overflow_location, parent_organization_id, timezone, updated_at
    FROM public.vita_partners;

CREATE VIEW analytics.vita_providers AS
    SELECT id, appointment_info, archived, coordinates, created_at, dates, details, hours, irs_id, languages, last_scrape_id, name, updated_at
    FROM public.vita_providers;
