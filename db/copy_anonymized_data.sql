create schema if not exists anon;

-- intake_site_drop_offs
drop table if exists anon.intake_site_drop_offs;
create table anon.intake_site_drop_offs as (select * from intake_site_drop_offs);
update anon.intake_site_drop_offs set additional_info = 'ANONYMIZED';
update anon.intake_site_drop_offs set name = 'ANONYMIZED';
update anon.intake_site_drop_offs set phone_number = 'ANONYMIZED';
update anon.intake_site_drop_offs set email = 'ANONYMIZED';

-- diy_intakes
drop table if exists anon.diy_intakes;
create table anon.diy_intakes as (select * from diy_intakes);
update anon.diy_intakes set email_address = 'ANONYMIZED';
update anon.diy_intakes set preferred_name = 'ANONYMIZED';

-- dependents
drop table if exists anon.dependents;
create table anon.dependents as (select * from dependents);
-- Anonymize birthday day and month
update anon.dependents set birth_date = to_date(concat('1/1/', extract(year from birth_date)), 'MM/DD/YYYY');
update anon.dependents set first_name = 'ANONYMIZED';
update anon.dependents set last_name = 'ANONYMIZED';

-- intakes
drop table if exists anon.intakes;
create table anon.intakes as (select * from intakes);
update anon.intakes set additional_info = 'ANONYMIZED';
update anon.intakes set email_address = 'ANONYMIZED';
update anon.intakes set encrypted_bank_account_number = 'ANONYMIZED';
update anon.intakes set encrypted_bank_account_number_iv = 'ANONYMIZED';
update anon.intakes set encrypted_bank_name = 'ANONYMIZED';
update anon.intakes set encrypted_bank_name_iv = 'ANONYMIZED';
update anon.intakes set encrypted_bank_routing_number = 'ANONYMIZED';
update anon.intakes set encrypted_bank_routing_number_iv = 'ANONYMIZED';
update anon.intakes set encrypted_primary_last_four_ssn = 'ANONYMIZED';
update anon.intakes set encrypted_primary_last_four_ssn_iv = 'ANONYMIZED';
update anon.intakes set encrypted_spouse_last_four_ssn = 'ANONYMIZED';
update anon.intakes set encrypted_spouse_last_four_ssn_iv = 'ANONYMIZED';
update anon.intakes set feedback = 'ANONYMIZED';
update anon.intakes set final_info = 'ANONYMIZED';
update anon.intakes set interview_timing_preference = 'ANONYMIZED';
update anon.intakes set other_income_types = 'ANONYMIZED';
update anon.intakes set phone_number = 'ANONYMIZED';
update anon.intakes set preferred_name = 'ANONYMIZED';
update anon.intakes set primary_birth_date = to_date(concat('1/1/', extract(year from primary_birth_date)), 'MM/DD/YYYY');
update anon.intakes set primary_consented_to_service_ip = '127.0.0.1';
update anon.intakes set primary_first_name = 'ANONYMIZED';
update anon.intakes set primary_last_name = 'ANONYMIZED';
update anon.intakes set sms_phone_number = 'ANONYMIZED';
update anon.intakes set spouse_birth_date = to_date(concat('1/1/', extract(year from spouse_birth_date)), 'MM/DD/YYYY');
update anon.intakes set spouse_consented_to_service_ip = '127.0.0.1';
update anon.intakes set spouse_email_address = 'ANONYMIZED';
update anon.intakes set spouse_first_name = 'ANONYMIZED';
update anon.intakes set spouse_last_name = 'ANONYMIZED';
update anon.intakes set street_address = 'ANONYMIZED';
update anon.intakes set zip_code = 'ANONYMIZED';

-- documents
drop table if exists anon.documents;
create table anon.documents as (select * from documents);
update anon.documents set display_name = 'ANONYMIZED';