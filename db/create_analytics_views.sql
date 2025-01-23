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

CREATE VIEW  analytics.analytics_events AS
    SELECT id, created_at, updated_at, client_id, event_type
    FROM public.analytics_events;

CREATE VIEW analytics.anonymized_diy_intake_csv_extracts AS
    SELECT id, created_at, record_count, run_at, updated_at
    FROM public.anonymized_diy_intake_csv_extracts;

CREATE VIEW analytics.anonymized_intake_csv_extracts AS
    SELECT id, created_at, record_count, run_at, updated_at
    FROM public.anonymized_intake_csv_extracts;

CREATE VIEW analytics.archived_dependents_2021 AS
    SELECT id, archived_intakes_2021_id, birth_date, born_in_2020, claim_anyway, cant_be_claimed_by_other, created_at,
           disabled, filed_joint_return, full_time_student, lived_with_more_than_six_months,
           meets_misc_qualifying_relative_requirements, months_in_home, no_ssn_atin, north_american_resident,
           on_visa, passed_away_2020, permanent_residence_with_client, permanently_totally_disabled, placed_for_adoption,
           provided_over_half_own_support, relationship, tin_type, updated_at, was_married, was_student
    FROM public.archived_dependents_2021;

CREATE VIEW analytics.archived_intakes_2021 AS
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
           phone_number_can_receive_texts, preferred_interview_language, primary_consented_to_service, primary_tin_type,
           received_alimony, received_irs_letter, refund_payment_method, reported_asset_sale_loss,
           reported_self_employment_loss, satisfaction_face,
           savings_purchase_bond, savings_split_refund, separated, separated_year, signature_method,
           sms_notification_opt_in, sold_a_home, sold_assets, source, spouse_consented_to_service,
           spouse_consented_to_service_at, spouse_had_disability, spouse_issued_identity_pin, spouse_tin_type, spouse_was_blind,
           spouse_was_full_time_student, spouse_was_on_visa, state, state_of_residence,
           updated_at, viewed_at_capacity, visitor_id, vita_partner_id, was_blind, was_full_time_student,
           was_on_visa, widowed, type, zip_code
    FROM public.archived_intakes_2021;

CREATE VIEW analytics.client_success_roles AS
    SELECT id, created_at, updated_at
    FROM public.client_success_roles;

CREATE VIEW analytics.clients AS
    SELECT id, attention_needed_since, consented_to_service_at, created_at, current_sign_in_at, failed_attempts, first_unanswered_incoming_interaction_at, flagged_at, last_13614c_update_at, last_incoming_interaction_at, last_internal_or_outgoing_interaction_at, last_sign_in_at, locked_at, login_requested_at, routing_method, sign_in_count, updated_at, vita_partner_id
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
    SELECT id, created_at, locale, referrer, source, updated_at, visitor_id, zip_code, clicked_chat_with_us_at
    FROM public.diy_intakes;

CREATE VIEW analytics.documents AS
    SELECT id, client_id, contact_record_id, contact_record_type, created_at, document_type, documents_request_id, intake_id, tax_return_id, updated_at, uploaded_by_id, uploaded_by_type
    FROM public.documents;

CREATE VIEW analytics.documents_requests AS
    SELECT id, created_at, client_id, updated_at
    FROM public.documents_requests;

CREATE VIEW analytics.efile_errors AS
    SELECT id, auto_cancel, auto_wait, category, code, created_at, expose, message, severity, source, updated_at
    FROM public.efile_errors;

CREATE VIEW analytics.efile_security_informations AS
    SELECT id, browser_language, client_id, client_system_time, created_at, device_id, efile_submission_id, ip_address, platform, recaptcha_score, timezone, timezone_offset, updated_at, user_agent
    FROM public.efile_security_informations;

CREATE VIEW analytics.efile_submission_transition_errors AS
    SELECT id, created_at, efile_error_id, efile_submission_id, efile_submission_transition_id, updated_at
    FROM public.efile_submission_transition_errors;

CREATE VIEW analytics.efile_submission_transitions AS
    SELECT id, created_at, efile_submission_id, most_recent, sort_key, to_state, updated_at
    FROM public.efile_submission_transitions;

CREATE VIEW analytics.efile_submissions AS
    SELECT id, created_at, irs_submission_id, tax_return_id, updated_at, claimed_eitc
    FROM public.efile_submissions;

CREATE VIEW analytics.experiments AS
    SELECT id, enabled, key, name
    FROM public.experiments;

CREATE VIEW analytics.experiment_participants AS
    SELECT id, record_type, treatment, experiment_id, record_id
    FROM public.experiment_participants;

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

CREATE VIEW analytics.incoming_portal_messages AS
    SELECT id, created_at, client_id
    FROM public.incoming_portal_messages;

CREATE VIEW analytics.intake_archives AS
SELECT id, needs_help_2017
FROM public.intake_archives;

CREATE VIEW analytics.intakes AS
    SELECT id, adopted_child, already_applied_for_stimulus, already_filed, balance_pay_from_bank,
           bank_account_type, bought_energy_efficient_items, bought_marketplace_health_insurance, city,
           claimed_by_another, client_id, completed_at, completed_yes_no_questions_at, continued_at_capacity,
           created_at, demographic_disability, demographic_english_conversation, demographic_english_reading,
           demographic_primary_american_indian_alaska_native, demographic_primary_asian,
           demographic_primary_black_african_american, demographic_primary_ethnicity,
           demographic_primary_native_hawaiian_pacific_islander, demographic_primary_prefer_not_to_answer_race,
           demographic_primary_white, demographic_questions_opt_in, demographic_spouse_american_indian_alaska_native,
           demographic_spouse_asian, demographic_spouse_black_african_american, demographic_spouse_ethnicity,
           demographic_spouse_native_hawaiian_pacific_islander, demographic_spouse_prefer_not_to_answer_race,
           demographic_spouse_white, demographic_veteran, divorced, divorced_year, eip_only,
           email_notification_opt_in, ever_married, feedback, feeling_about_taxes, filing_for_stimulus, filing_joint,
           had_asset_sale_income, had_debt_forgiven, had_dependents, had_disability, had_disability_income,
           had_disaster_loss, had_farm_income, had_gambling_income, had_hsa, had_interest_income,
           had_local_tax_refund, had_other_income, had_rental_income, had_retirement_income,
           had_self_employment_income, had_social_security_income, had_social_security_or_retirement,
           had_tax_credit_disallowed, had_tips, had_unemployment_income, had_wages, home_location,
           income_over_limit, irs_language_preference, issued_identity_pin, job_count, lived_with_spouse, locale,
           made_estimated_tax_payments, married, multiple_states, needs_help_2016, needs_help_2018,
           needs_help_2019, needs_help_2020, needs_help_2021, needs_help_2022,
           needs_help_2023, needs_help_2024, no_eligibility_checks_apply, no_ssn, paid_alimony,
           paid_charitable_contributions, paid_dependent_care, paid_local_tax, paid_medical_expenses,
           paid_mortgage_interest, paid_post_secondary_educational_expenses, paid_retirement_contributions,
           paid_school_supplies, paid_student_loan_interest,phone_number_can_receive_texts,
           preferred_interview_language, primary_consented_to_service, primary_tin_type,
           received_alimony, received_irs_letter, referrer, refund_payment_method, reported_asset_sale_loss,
           reported_self_employment_loss, satisfaction_face,
           savings_purchase_bond, savings_split_refund, separated, separated_year, signature_method,
           sms_notification_opt_in, sold_a_home, sold_assets, source, spouse_consented_to_service,
           spouse_consented_to_service_at, spouse_had_disability, spouse_issued_identity_pin, spouse_tin_type, spouse_was_blind,
           spouse_was_full_time_student, state, state_of_residence, triage_filing_frequency, triage_filing_status,
           updated_at, viewed_at_capacity, visitor_id, vita_partner_id, was_blind, was_full_time_student,
           widowed, type, zip_code
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

CREATE VIEW analytics.outgoing_message_statuses AS
    SELECT id, parent_id, parent_type, created_at, error_code, message_id, message_type, delivery_status, updated_at
    FROM public.outgoing_message_statuses;

CREATE VIEW analytics.outgoing_text_messages AS
    SELECT id, client_id, created_at, error_code, sent_at, twilio_sid, twilio_status, updated_at, user_id
    FROM public.outgoing_text_messages;

CREATE VIEW analytics.provider_scrapes AS
    SELECT id, archived_count, changed_count, created_at, created_count, updated_at
    FROM public.provider_scrapes;

CREATE VIEW analytics.signups AS
    SELECT id, created_at, updated_at
    FROM public.signups;

CREATE VIEW analytics.site_coordinator_roles AS
    SELECT id, created_at, updated_at
    FROM public.site_coordinator_roles;

CREATE VIEW analytics.source_parameters AS
    SELECT id, code, created_at, updated_at, vita_partner_id
    FROM public.source_parameters;

CREATE VIEW analytics.system_notes AS
    SELECT id, client_id, created_at, type, updated_at, user_id
    FROM public.system_notes;

CREATE VIEW analytics.tax_returns AS
    SELECT id, assigned_user_id, certification_level, client_id, created_at, is_hsa,
           primary_signed_at, ready_for_prep_at, service_type, spouse_signed_at,
           current_state, updated_at, year, is_ctc
    FROM public.tax_returns;

CREATE VIEW analytics.team_member_roles AS
    SELECT id, created_at, updated_at
    FROM public.team_member_roles;

CREATE VIEW analytics.users AS
    SELECT id, created_at, current_sign_in_at, failed_attempts, invitation_accepted_at, invitation_created_at,
           invitation_limit, invitation_sent_at, invitations_count, invited_by_id, last_sign_in_at,
           locked_at, reset_password_sent_at, role_id, role_type, sign_in_count, suspended_at, timezone, updated_at
    FROM public.users;

CREATE VIEW analytics.vita_partner_zip_codes AS
    SELECT id, created_at, updated_at, vita_partner_id, zip_code
    FROM public.vita_partner_zip_codes;

CREATE VIEW analytics.vita_partners AS
    SELECT id, archived, capacity_limit, coalition_id, created_at, logo_path, name, national_overflow_location, parent_organization_id, timezone, updated_at
    FROM public.vita_partners;

CREATE VIEW analytics.vita_providers AS
    SELECT id, appointment_info, archived, coordinates, created_at, dates, details, hours, irs_id, languages, last_scrape_id, name, updated_at
    FROM public.vita_providers;

CREATE view analytics.state_ids AS
    SELECT id, created_at, id_type, updated_at
    FROM public.state_ids;

CREATE view analytics.state_file1099_gs AS
    SELECT id, updated_at, created_at, intake_id, intake_type
    FROM public.state_file1099_gs;

CREATE view analytics.state_file_dependents AS
    SELECT id, updated_at, created_at, intake_id, intake_type
    FROM public.state_file_dependents;

CREATE view analytics.state_file_az_intakes AS
    SELECT id, updated_at, armed_forces_member, charitable_contributions, consented_to_terms_and_conditions, contact_preference, created_at, current_step, eligibility_529_for_non_qual_expense, eligibility_lived_in_state, eligibility_married_filing_separately, eligibility_out_of_state_income, hashed_ssn, primary_esigned_at, primary_state_id_id, raw_direct_file_data, routing_number, sign_in_count, spouse_state_id_id, tribal_member, was_incarcerated
    FROM public.state_file_az_intakes;

CREATE view analytics.state_file_ny_intakes AS
    SELECT id, updated_at, consented_to_terms_and_conditions, contact_preference, created_at, current_step, eligibility_lived_in_state, eligibility_out_of_state_income, eligibility_part_year_nyc_resident, eligibility_withdrew_529, eligibility_yonkers, hashed_ssn, nyc_maintained_home, nyc_residency, primary_birth_date, primary_esigned_at, primary_state_id_id, raw_direct_file_data, routing_number, sign_in_count, spouse_state_id_id, untaxed_out_of_state_purchases
    FROM public.state_file_ny_intakes;

CREATE view analytics.state_file_w2s AS
SELECT id, employer_state_id_num, local_income_tax_amount, local_wages_and_tips_amount, locality_nm, state_file_intake_type, state_income_tax_amount, state_wages_amount, w2_index, created_at, updated_at, state_file_intake_id
FROM public.state_file_w2s;
