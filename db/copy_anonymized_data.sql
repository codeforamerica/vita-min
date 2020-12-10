-- CREATE NEW SCHEMA
create schema if not exists anon2020;

-- COPY DATA
drop table if exists anon2020.active_storage_attachments;
create table anon2020.active_storage_attachments as (select * from public.active_storage_attachments);
drop table if exists anon2020.active_storage_blobs;
create table anon2020.active_storage_blobs as (select * from public.active_storage_blobs);
drop table if exists anon2020.anonymized_diy_intake_csv_extracts;
create table anon2020.anonymized_diy_intake_csv_extracts as (select * from public.anonymized_diy_intake_csv_extracts);
drop table if exists anon2020.anonymized_intake_csv_extracts;
create table anon2020.anonymized_intake_csv_extracts as (select * from public.anonymized_intake_csv_extracts);
drop table if exists anon2020.ar_internal_metadata;
create table anon2020.ar_internal_metadata as (select * from public.ar_internal_metadata);
drop table if exists anon2020.clients;
create table anon2020.clients as (select * from public.clients);
drop table if exists anon2020.delayed_jobs;
create table anon2020.delayed_jobs as (select * from public.delayed_jobs);
drop table if exists anon2020.dependents;
create table anon2020.dependents as (select * from public.dependents);
drop table if exists anon2020.diy_intakes;
create table anon2020.diy_intakes as (select * from public.diy_intakes);
drop table if exists anon2020.documents;
create table anon2020.documents as (select * from public.documents);
drop table if exists anon2020.documents_requests;
create table anon2020.documents_requests as (select * from public.documents_requests);
drop table if exists anon2020.idme_users;
create table anon2020.idme_users as (select * from public.idme_users);
drop table if exists anon2020.incoming_emails;
create table anon2020.incoming_emails as (select * from public.incoming_emails);
drop table if exists anon2020.incoming_text_messages;
create table anon2020.incoming_text_messages as (select * from public.incoming_text_messages);
drop table if exists anon2020.intake_site_drop_offs;
create table anon2020.intake_site_drop_offs as (select * from public.intake_site_drop_offs);
drop table if exists anon2020.intakes;
create table anon2020.intakes as (select * from public.intakes);
drop table if exists anon2020.notes;
create table anon2020.notes as (select * from public.notes);
drop table if exists anon2020.outgoing_emails;
create table anon2020.outgoing_emails as (select * from public.outgoing_emails);
drop table if exists anon2020.outgoing_text_messages;
create table anon2020.outgoing_text_messages as (select * from public.outgoing_text_messages);
drop table if exists anon2020.provider_scrapes;
create table anon2020.provider_scrapes as (select * from public.provider_scrapes);
drop table if exists anon2020.schema_migrations;
create table anon2020.schema_migrations as (select * from public.schema_migrations);
drop table if exists anon2020.signups;
create table anon2020.signups as (select * from public.signups);
drop table if exists anon2020.source_parameters;
create table anon2020.source_parameters as (select * from public.source_parameters);
drop table if exists anon2020.spatial_ref_sys;
create table anon2020.spatial_ref_sys as (select * from public.spatial_ref_sys);
drop table if exists anon2020.states;
create table anon2020.states as (select * from public.states);
drop table if exists anon2020.states_vita_partners;
create table anon2020.states_vita_partners as (select * from public.states_vita_partners);
drop table if exists anon2020.stimulus_triages;
create table anon2020.stimulus_triages as (select * from public.stimulus_triages);
drop table if exists anon2020.system_notes;
create table anon2020.system_notes as (select * from public.system_notes);
drop table if exists anon2020.tax_returns;
create table anon2020.tax_returns as (select * from public.tax_returns);
drop table if exists anon2020.ticket_statuses;
create table anon2020.ticket_statuses as (select * from public.ticket_statuses);
drop table if exists anon2020.users;
create table anon2020.users as (select * from public.users);
drop table if exists anon2020.users_vita_partners;
create table anon2020.users_vita_partners as (select * from public.users_vita_partners);
drop table if exists anon2020.vita_partners;
create table anon2020.vita_partners as (select * from public.vita_partners);
drop table if exists anon2020.vita_providers;
create table anon2020.vita_providers as (select * from public.vita_providers);

-- ANONYMIZE DATA

-- intake_site_drop_offs
update anon2020.intake_site_drop_offs
set additional_info = case when additional_info is null then additional_info else 'ANONYMIZED' end
  , name            = case when name is null then name else 'ANONYMIZED' end
  , phone_number    = case when phone_number is null then phone_number else 'ANONYMIZED' end
  , email           = case when email is null then email else 'ANONYMIZED' end;

-- diy_intakes
update anon2020.diy_intakes
set email_address  = case when email_address is null then email_address else 'ANONYMIZED' end
  , preferred_name = case when preferred_name is null then preferred_name else 'ANONYMIZED' end;

-- dependents
update anon2020.dependents
set birth_date = case when birth_date is null then birth_date else to_date(concat('1/1/', extract(year from birth_date)), 'MM/DD/YYYY') end
  , first_name = case when first_name is null then first_name else 'ANONYMIZED' end
  , last_name  = case when last_name is null then last_name else 'ANONYMIZED' end;

-- documents
update anon2020.documents
set display_name = case when display_name is null then display_name else 'ANONYMIZED' end;

-- delayed_jobs
truncate anon2020.idme_users;

-- intakes
update anon2020.intakes
set additional_info                    = case when additional_info is null then additional_info else 'ANONYMIZED' end
  , email_address                      = case when email_address is null then email_address else 'ANONYMIZED' end
  , encrypted_bank_account_number      = case when encrypted_bank_account_number is null then encrypted_bank_account_number else 'ANONYMIZED' end
  , encrypted_bank_account_number_iv   = case when encrypted_bank_account_number_iv is null then encrypted_bank_account_number_iv else 'ANONYMIZED' end
  , encrypted_bank_name                = case when encrypted_bank_name is null then encrypted_bank_name else 'ANONYMIZED' end
  , encrypted_bank_name_iv             = case when encrypted_bank_name_iv is null then encrypted_bank_name_iv else 'ANONYMIZED' end
  , encrypted_bank_routing_number      = case when encrypted_bank_routing_number is null then encrypted_bank_routing_number else 'ANONYMIZED' end
  , encrypted_bank_routing_number_iv   = case when encrypted_bank_routing_number_iv is null then encrypted_bank_routing_number_iv else 'ANONYMIZED' end
  , encrypted_primary_last_four_ssn    = case when encrypted_primary_last_four_ssn is null then encrypted_primary_last_four_ssn else 'ANONYMIZED' end
  , encrypted_primary_last_four_ssn_iv = case when encrypted_primary_last_four_ssn_iv is null then encrypted_primary_last_four_ssn_iv else 'ANONYMIZED' end
  , encrypted_spouse_last_four_ssn     = case when encrypted_spouse_last_four_ssn is null then encrypted_spouse_last_four_ssn else 'ANONYMIZED' end
  , encrypted_spouse_last_four_ssn_iv  = case when encrypted_spouse_last_four_ssn_iv is null then encrypted_spouse_last_four_ssn_iv else 'ANONYMIZED' end
  , feedback                           = case when feedback is null then feedback else 'ANONYMIZED' end
  , final_info                         = case when final_info is null then final_info else 'ANONYMIZED' end
  , interview_timing_preference        = case when interview_timing_preference is null then interview_timing_preference else 'ANONYMIZED' end
  , other_income_types                 = case when other_income_types is null then other_income_types else 'ANONYMIZED' end
  , phone_number                       = case when phone_number is null then phone_number else 'ANONYMIZED' end
  , preferred_name                     = case when preferred_name is null then preferred_name else 'ANONYMIZED' end
  -- Anonymize birthday day and month
  , primary_birth_date                 = case when primary_birth_date is null then primary_birth_date else to_date(concat('1/1/', extract(year from primary_birth_date)), 'MM/DD/YYYY') end
  , primary_consented_to_service_ip    = case when primary_consented_to_service_ip is null then primary_consented_to_service_ip else '127.0.0.1' end
  , primary_first_name                 = case when primary_first_name is null then primary_first_name else 'ANONYMIZED' end
  , primary_last_name                  = case when primary_last_name is null then primary_last_name else 'ANONYMIZED' end
  , referrer                           = case when referrer is null then referrer else 'ANONYMIZED' end
  , sms_phone_number                   = case when sms_phone_number is null then sms_phone_number else 'ANONYMIZED' end
  , spouse_birth_date                  = case when spouse_birth_date is null then spouse_birth_date else to_date(concat('1/1/', extract(year from spouse_birth_date)), 'MM/DD/YYYY') end
  , spouse_consented_to_service_ip     = case when spouse_consented_to_service_ip is null then spouse_consented_to_service_ip else '127.0.0.1' end
  , spouse_email_address               = case when spouse_email_address is null then spouse_email_address else 'ANONYMIZED' end
  , spouse_first_name                  = case when spouse_first_name is null then spouse_first_name else 'ANONYMIZED' end
  , spouse_last_name                   = case when spouse_last_name is null then spouse_last_name else 'ANONYMIZED' end
  , street_address                     = case when street_address is null then street_address else 'ANONYMIZED' end
  , zip_code                           = case when zip_code is null then zip_code else 'ANONYMIZED' end;

-- active_storage_blobs
update anon2020.active_storage_blobs
set filename = case when filename is null then filename else 'ANONYMIZED' end;

-- delayed_jobs
truncate anon2020.delayed_jobs;

-- incoming_emails
update anon2020.incoming_emails
set stripped_signature = case when stripped_signature is null then stripped_signature else 'ANONYMIZED' end
  , stripped_text      = case when stripped_text is null then stripped_text else 'ANONYMIZED' end
  , stripped_html      = case when stripped_html is null then stripped_html else 'ANONYMIZED' end
  , body_plain         = case when body_plain is null then body_plain else 'ANONYMIZED' end
  , body_html          = case when body_html is null then body_html else 'ANONYMIZED' end
  , subject            = case when subject is null then subject else 'ANONYMIZED' end
  , recipient          = case when recipient is null then recipient else 'ANONYMIZED' end
  , sender             = case when sender is null then sender else 'ANONYMIZED' end
  , received           = case when received is null then received else 'ANONYMIZED' end
  , "from"             = case when "from" is null then "from" else 'ANONYMIZED' end
  , "to"               = case when "to" is null then "to" else 'ANONYMIZED' end;

-- incoming_text_messages
update anon2020.incoming_text_messages
set body              = case when body is null then body else 'ANONYMIZED' end
  , from_phone_number = case when from_phone_number is null then from_phone_number else 'ANONYMIZED' end;

-- notes
update anon2020.notes
set body              = case when body is null then body else 'ANONYMIZED' end;

-- outgoing_emails
update anon2020.outgoing_emails
set body    = case when body is null then body else 'ANONYMIZED' end
  , subject = case when subject is null then subject else 'ANONYMIZED' end
  , "to"    = case when "to" is null then "to" else 'ANONYMIZED' end;

-- system_notes
update anon2020.system_notes
set body = case when body is null then body else 'ANONYMIZED' end;

-- stimulus_triages
update anon2020.stimulus_triages
set referrer = case when referrer is null then referrer else 'ANONYMIZED' end;

-- users
update anon2020.users
set name                      = case when name is null then name else 'ANONYMIZED' end
  , email                     = case when email is null then email else 'ANONYMIZED' end
  , encrypted_access_token    = case when encrypted_access_token is null then encrypted_access_token else 'ANONYMIZED' end
  , encrypted_access_token_iv = case when encrypted_access_token_iv is null then encrypted_access_token_iv else 'ANONYMIZED' end
  , encrypted_password        = case when encrypted_password is null then encrypted_password else 'ANONYMIZED' end
  , current_sign_in_ip        = case when current_sign_in_ip is null then current_sign_in_ip else '127.0.0.1' end
  , last_sign_in_ip           = case when last_sign_in_ip is null then last_sign_in_ip else '127.0.0.1' end
  , timezone                  = case when timezone is null then timezone else 'ANONYMIZED' end;