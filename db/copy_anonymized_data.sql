-- CREATE NEW SCHEMA
create schema if not exists anon2020;

-- COPY DATA
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
set additional_info = 'ANONYMIZED'
  , name            = 'ANONYMIZED'
  , phone_number    = 'ANONYMIZED'
  , email           = 'ANONYMIZED';

-- diy_intakes
update anon2020.diy_intakes
set email_address  = 'ANONYMIZED'
  , preferred_name = 'ANONYMIZED';

-- dependents
update anon2020.dependents
set birth_date = to_date(concat('1/1/', extract(year from birth_date)), 'MM/DD/YYYY')
  , first_name = 'ANONYMIZED'
  , last_name  = 'ANONYMIZED';

-- intakes
update anon2020.documents
set display_name = 'ANONYMIZED';

-- documents
update anon2020.intakes
set additional_info                    = 'ANONYMIZED'
  , email_address                      = 'ANONYMIZED'
  , encrypted_bank_account_number      = 'ANONYMIZED'
  , encrypted_bank_account_number_iv   = 'ANONYMIZED'
  , encrypted_bank_name                = 'ANONYMIZED'
  , encrypted_bank_name_iv             = 'ANONYMIZED'
  , encrypted_bank_routing_number      = 'ANONYMIZED'
  , encrypted_bank_routing_number_iv   = 'ANONYMIZED'
  , encrypted_primary_last_four_ssn    = 'ANONYMIZED'
  , encrypted_primary_last_four_ssn_iv = 'ANONYMIZED'
  , encrypted_spouse_last_four_ssn     = 'ANONYMIZED'
  , encrypted_spouse_last_four_ssn_iv  = 'ANONYMIZED'
  , feedback                           = 'ANONYMIZED'
  , final_info                         = 'ANONYMIZED'
  , interview_timing_preference        = 'ANONYMIZED'
  , other_income_types                 = 'ANONYMIZED'
  , phone_number                       = 'ANONYMIZED'
  , preferred_name                     = 'ANONYMIZED'
  -- Anonymize birthday day and month
  , primary_birth_date                 = to_date(concat('1/1/', extract(year from primary_birth_date)), 'MM/DD/YYYY')
  , primary_consented_to_service_ip    = '127.0.0.1'
  , primary_first_name                 = 'ANONYMIZED'
  , primary_last_name                  = 'ANONYMIZED'
  , referrer                           = 'ANONYMIZED'
  , sms_phone_number                   = 'ANONYMIZED'
  , spouse_birth_date                  = to_date(concat('1/1/', extract(year from spouse_birth_date)), 'MM/DD/YYYY')
  , spouse_consented_to_service_ip     = '127.0.0.1'
  , spouse_email_address               = 'ANONYMIZED'
  , spouse_first_name                  = 'ANONYMIZED'
  , spouse_last_name                   = 'ANONYMIZED'
  , street_address                     = 'ANONYMIZED'
  , zip_code                           = 'ANONYMIZED';

-- active_storage_blobs
update anon2020.active_storage_blobs
set filename = 'ANONYMIZED';

-- delayed_jobs
truncate anon2020.delayed_jobs;

-- incoming_emails
update anon2020.incoming_emails
set stripped_signature = 'ANONYMIZED'
  , stripped_text      = 'ANONYMIZED'
  , stripped_html      = 'ANONYMIZED'
  , body_plain         = 'ANONYMIZED'
  , body_html          = 'ANONYMIZED'
  , subject            = 'ANONYMIZED'
  , recipient          = 'ANONYMIZED'
  , sender             = 'ANONYMIZED'
  , received           = 'ANONYMIZED'
  , "from"             = 'ANONYMIZED'
  , "to"               = 'ANONYMIZED';

-- incoming_text_messages
update anon2020.incoming_text_messages
set body              = 'ANONYMIZED'
  , from_phone_number = 'ANONYMIZED';

-- notes
update anon2020.notes
set body              = 'ANONYMIZED';

-- outgoing_emails
update anon2020.outgoing_emails
set body    = 'ANONYMIZED'
  , subject = 'ANONYMIZED'
  , "to"    = 'ANONYMIZED';

-- system_notes
update anon2020.system_notes
set body = 'ANONYMIZED';

-- stimulus_triages
update anon2020.stimulus_triages
set referrer = 'ANONYMIZED';

-- users
update anon2020.users
set name                      = 'ANONYMIZED'
  , email                     = 'ANONYMIZED'
  , encrypted_access_token    = 'ANONYMIZED'
  , encrypted_access_token_iv = 'ANONYMIZED'
  , encrypted_password        = 'ANONYMIZED'
  , current_sign_in_ip        = '127.0.0.1'
  , last_sign_in_ip           = '127.0.0.1'
  , timezone                  = 'ANONYMIZED';