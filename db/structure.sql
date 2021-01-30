SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_logs (
    id bigint NOT NULL,
    client_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    ip_address inet,
    updated_at timestamp(6) without time zone NOT NULL,
    user_agent character varying NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: access_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.access_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.access_logs_id_seq OWNED BY public.access_logs.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    name character varying NOT NULL,
    record_id bigint NOT NULL,
    record_type character varying NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    content_type character varying,
    created_at timestamp without time zone NOT NULL,
    filename character varying NOT NULL,
    key character varying NOT NULL,
    metadata text
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: admin_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_roles (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_roles_id_seq OWNED BY public.admin_roles.id;


--
-- Name: anonymized_diy_intake_csv_extracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.anonymized_diy_intake_csv_extracts (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    record_count integer,
    run_at timestamp without time zone,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: anonymized_diy_intake_csv_extracts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anonymized_diy_intake_csv_extracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anonymized_diy_intake_csv_extracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.anonymized_diy_intake_csv_extracts_id_seq OWNED BY public.anonymized_diy_intake_csv_extracts.id;


--
-- Name: anonymized_intake_csv_extracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.anonymized_intake_csv_extracts (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    record_count integer,
    run_at timestamp without time zone,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: anonymized_intake_csv_extracts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anonymized_intake_csv_extracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anonymized_intake_csv_extracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.anonymized_intake_csv_extracts_id_seq OWNED BY public.anonymized_intake_csv_extracts.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: client_success_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_success_roles (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: client_success_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_success_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_success_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_success_roles_id_seq OWNED BY public.client_success_roles.id;


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
    id bigint NOT NULL,
    attention_needed_since timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    current_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    failed_attempts integer DEFAULT 0 NOT NULL,
    last_incoming_interaction_at timestamp without time zone,
    last_interaction_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    last_sign_in_ip inet,
    locked_at timestamp without time zone,
    login_requested_at timestamp without time zone,
    login_token character varying,
    routing_method integer,
    sign_in_count integer DEFAULT 0 NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    vita_partner_id bigint
);


--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clients_id_seq OWNED BY public.clients.id;


--
-- Name: coalition_lead_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coalition_lead_roles (
    id bigint NOT NULL,
    coalition_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: coalition_lead_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.coalition_lead_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coalition_lead_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.coalition_lead_roles_id_seq OWNED BY public.coalition_lead_roles.id;


--
-- Name: coalitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coalitions (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    name character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: coalitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.coalitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coalitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.coalitions_id_seq OWNED BY public.coalitions.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id bigint NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    failed_at timestamp without time zone,
    handler text NOT NULL,
    last_error text,
    locked_at timestamp without time zone,
    locked_by character varying,
    priority integer DEFAULT 0 NOT NULL,
    queue character varying,
    run_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: dependents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dependents (
    id bigint NOT NULL,
    birth_date date,
    created_at timestamp without time zone NOT NULL,
    disabled integer DEFAULT 0 NOT NULL,
    first_name character varying,
    intake_id bigint NOT NULL,
    last_name character varying,
    months_in_home integer,
    north_american_resident integer DEFAULT 0 NOT NULL,
    on_visa integer DEFAULT 0 NOT NULL,
    relationship character varying,
    updated_at timestamp without time zone NOT NULL,
    was_married integer DEFAULT 0 NOT NULL,
    was_student integer DEFAULT 0 NOT NULL
);


--
-- Name: dependents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dependents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dependents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dependents_id_seq OWNED BY public.dependents.id;


--
-- Name: diy_intakes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diy_intakes (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    email_address character varying,
    locale character varying,
    preferred_name character varying,
    referrer character varying,
    requester_id bigint,
    source character varying,
    state_of_residence character varying,
    ticket_id bigint,
    token character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    visitor_id character varying
);


--
-- Name: diy_intakes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.diy_intakes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diy_intakes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.diy_intakes_id_seq OWNED BY public.diy_intakes.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id bigint NOT NULL,
    client_id bigint,
    contact_record_id bigint,
    contact_record_type character varying,
    created_at timestamp without time zone NOT NULL,
    display_name character varying,
    document_type character varying DEFAULT 'Other'::character varying NOT NULL,
    documents_request_id bigint,
    intake_id bigint,
    tax_return_id bigint,
    updated_at timestamp without time zone NOT NULL,
    uploaded_by_id bigint,
    uploaded_by_type character varying,
    zendesk_ticket_id bigint
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: documents_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents_requests (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    intake_id bigint,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: documents_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_requests_id_seq OWNED BY public.documents_requests.id;


--
-- Name: greeter_coalition_join_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.greeter_coalition_join_records (
    id bigint NOT NULL,
    coalition_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    greeter_role_id bigint NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: greeter_coalition_join_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.greeter_coalition_join_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: greeter_coalition_join_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.greeter_coalition_join_records_id_seq OWNED BY public.greeter_coalition_join_records.id;


--
-- Name: greeter_organization_join_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.greeter_organization_join_records (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    greeter_role_id bigint NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    vita_partner_id bigint NOT NULL
);


--
-- Name: greeter_organization_join_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.greeter_organization_join_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: greeter_organization_join_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.greeter_organization_join_records_id_seq OWNED BY public.greeter_organization_join_records.id;


--
-- Name: greeter_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.greeter_roles (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: greeter_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.greeter_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: greeter_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.greeter_roles_id_seq OWNED BY public.greeter_roles.id;


--
-- Name: incoming_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incoming_emails (
    id bigint NOT NULL,
    attachment_count integer,
    body_html character varying,
    body_plain character varying NOT NULL,
    client_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    "from" character varying NOT NULL,
    message_id character varying,
    received character varying,
    received_at timestamp without time zone NOT NULL,
    recipient character varying NOT NULL,
    sender character varying NOT NULL,
    stripped_html character varying,
    stripped_signature character varying,
    stripped_text character varying,
    subject character varying,
    "to" character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_agent character varying
);


--
-- Name: incoming_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incoming_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incoming_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incoming_emails_id_seq OWNED BY public.incoming_emails.id;


--
-- Name: incoming_text_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incoming_text_messages (
    id bigint NOT NULL,
    body character varying,
    client_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    from_phone_number character varying NOT NULL,
    received_at timestamp without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: incoming_text_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incoming_text_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incoming_text_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incoming_text_messages_id_seq OWNED BY public.incoming_text_messages.id;


--
-- Name: intakes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.intakes (
    id bigint NOT NULL,
    additional_info character varying,
    adopted_child integer DEFAULT 0 NOT NULL,
    already_applied_for_stimulus integer DEFAULT 0 NOT NULL,
    already_filed integer DEFAULT 0 NOT NULL,
    anonymous boolean DEFAULT false NOT NULL,
    balance_pay_from_bank integer DEFAULT 0 NOT NULL,
    bank_account_type integer DEFAULT 0 NOT NULL,
    bought_energy_efficient_items integer,
    bought_health_insurance integer DEFAULT 0 NOT NULL,
    city character varying,
    claimed_by_another integer DEFAULT 0 NOT NULL,
    client_id bigint,
    completed_at timestamp without time zone,
    completed_intake_sent_to_zendesk boolean,
    completed_yes_no_questions_at timestamp without time zone,
    continued_at_capacity boolean DEFAULT false,
    created_at timestamp without time zone,
    demographic_disability integer DEFAULT 0 NOT NULL,
    demographic_english_conversation integer DEFAULT 0 NOT NULL,
    demographic_english_reading integer DEFAULT 0 NOT NULL,
    demographic_primary_american_indian_alaska_native boolean,
    demographic_primary_asian boolean,
    demographic_primary_black_african_american boolean,
    demographic_primary_ethnicity integer DEFAULT 0 NOT NULL,
    demographic_primary_native_hawaiian_pacific_islander boolean,
    demographic_primary_prefer_not_to_answer_race boolean,
    demographic_primary_white boolean,
    demographic_questions_opt_in integer DEFAULT 0 NOT NULL,
    demographic_spouse_american_indian_alaska_native boolean,
    demographic_spouse_asian boolean,
    demographic_spouse_black_african_american boolean,
    demographic_spouse_ethnicity integer DEFAULT 0 NOT NULL,
    demographic_spouse_native_hawaiian_pacific_islander boolean,
    demographic_spouse_prefer_not_to_answer_race boolean,
    demographic_spouse_white boolean,
    demographic_veteran integer DEFAULT 0 NOT NULL,
    divorced integer DEFAULT 0 NOT NULL,
    divorced_year character varying,
    eip_only boolean,
    email_address character varying,
    email_notification_opt_in integer DEFAULT 0 NOT NULL,
    encrypted_bank_account_number character varying,
    encrypted_bank_account_number_iv character varying,
    encrypted_bank_name character varying,
    encrypted_bank_name_iv character varying,
    encrypted_bank_routing_number character varying,
    encrypted_bank_routing_number_iv character varying,
    encrypted_primary_last_four_ssn character varying,
    encrypted_primary_last_four_ssn_iv character varying,
    encrypted_spouse_last_four_ssn character varying,
    encrypted_spouse_last_four_ssn_iv character varying,
    ever_married integer DEFAULT 0 NOT NULL,
    feedback character varying,
    feeling_about_taxes integer DEFAULT 0 NOT NULL,
    filing_for_stimulus integer DEFAULT 0 NOT NULL,
    filing_joint integer DEFAULT 0 NOT NULL,
    final_info character varying,
    had_asset_sale_income integer DEFAULT 0 NOT NULL,
    had_debt_forgiven integer DEFAULT 0 NOT NULL,
    had_dependents integer DEFAULT 0 NOT NULL,
    had_disability integer DEFAULT 0 NOT NULL,
    had_disability_income integer DEFAULT 0 NOT NULL,
    had_disaster_loss integer DEFAULT 0 NOT NULL,
    had_farm_income integer DEFAULT 0 NOT NULL,
    had_gambling_income integer DEFAULT 0 NOT NULL,
    had_hsa integer DEFAULT 0 NOT NULL,
    had_interest_income integer DEFAULT 0 NOT NULL,
    had_local_tax_refund integer DEFAULT 0 NOT NULL,
    had_other_income integer DEFAULT 0 NOT NULL,
    had_rental_income integer DEFAULT 0 NOT NULL,
    had_retirement_income integer DEFAULT 0 NOT NULL,
    had_self_employment_income integer DEFAULT 0 NOT NULL,
    had_social_security_income integer DEFAULT 0 NOT NULL,
    had_social_security_or_retirement integer DEFAULT 0 NOT NULL,
    had_student_in_family integer DEFAULT 0 NOT NULL,
    had_tax_credit_disallowed integer DEFAULT 0 NOT NULL,
    had_tips integer DEFAULT 0 NOT NULL,
    had_unemployment_income integer DEFAULT 0 NOT NULL,
    had_wages integer DEFAULT 0 NOT NULL,
    has_enqueued_ticket_creation boolean DEFAULT false,
    income_over_limit integer DEFAULT 0 NOT NULL,
    intake_pdf_sent_to_zendesk boolean DEFAULT false NOT NULL,
    intake_ticket_id bigint,
    intake_ticket_requester_id bigint,
    interview_timing_preference character varying,
    issued_identity_pin integer DEFAULT 0 NOT NULL,
    job_count integer,
    lived_with_spouse integer DEFAULT 0 NOT NULL,
    locale character varying,
    made_estimated_tax_payments integer DEFAULT 0 NOT NULL,
    married integer DEFAULT 0 NOT NULL,
    multiple_states integer DEFAULT 0 NOT NULL,
    needs_help_2016 integer DEFAULT 0 NOT NULL,
    needs_help_2017 integer DEFAULT 0 NOT NULL,
    needs_help_2018 integer DEFAULT 0 NOT NULL,
    needs_help_2019 integer DEFAULT 0 NOT NULL,
    needs_help_2020 integer DEFAULT 0 NOT NULL,
    no_eligibility_checks_apply integer DEFAULT 0 NOT NULL,
    no_ssn integer DEFAULT 0 NOT NULL,
    other_income_types character varying,
    paid_alimony integer DEFAULT 0 NOT NULL,
    paid_charitable_contributions integer DEFAULT 0 NOT NULL,
    paid_dependent_care integer DEFAULT 0 NOT NULL,
    paid_local_tax integer DEFAULT 0 NOT NULL,
    paid_medical_expenses integer DEFAULT 0 NOT NULL,
    paid_mortgage_interest integer DEFAULT 0 NOT NULL,
    paid_retirement_contributions integer DEFAULT 0 NOT NULL,
    paid_school_supplies integer DEFAULT 0 NOT NULL,
    paid_student_loan_interest integer DEFAULT 0 NOT NULL,
    phone_number character varying,
    phone_number_can_receive_texts integer DEFAULT 0 NOT NULL,
    preferred_interview_language character varying,
    preferred_name character varying,
    primary_birth_date date,
    primary_consented_to_service integer DEFAULT 0 NOT NULL,
    primary_consented_to_service_at timestamp without time zone,
    primary_consented_to_service_ip inet,
    primary_first_name character varying,
    primary_intake_id integer,
    primary_last_name character varying,
    received_alimony integer DEFAULT 0 NOT NULL,
    received_homebuyer_credit integer DEFAULT 0 NOT NULL,
    received_irs_letter integer DEFAULT 0 NOT NULL,
    referrer character varying,
    refund_payment_method integer DEFAULT 0 NOT NULL,
    reported_asset_sale_loss integer DEFAULT 0 NOT NULL,
    reported_self_employment_loss integer DEFAULT 0 NOT NULL,
    requested_docs_token character varying,
    requested_docs_token_created_at timestamp without time zone,
    routed_at timestamp without time zone,
    routing_criteria character varying,
    routing_value character varying,
    satisfaction_face integer DEFAULT 0 NOT NULL,
    savings_purchase_bond integer DEFAULT 0 NOT NULL,
    savings_split_refund integer DEFAULT 0 NOT NULL,
    separated integer DEFAULT 0 NOT NULL,
    separated_year character varying,
    signature_method integer DEFAULT 0 NOT NULL,
    sms_notification_opt_in integer DEFAULT 0 NOT NULL,
    sms_phone_number character varying,
    sold_a_home integer DEFAULT 0 NOT NULL,
    sold_assets integer DEFAULT 0 NOT NULL,
    source character varying,
    spouse_auth_token character varying,
    spouse_birth_date date,
    spouse_consented_to_service integer DEFAULT 0 NOT NULL,
    spouse_consented_to_service_at timestamp without time zone,
    spouse_consented_to_service_ip inet,
    spouse_email_address character varying,
    spouse_first_name character varying,
    spouse_had_disability integer DEFAULT 0 NOT NULL,
    spouse_issued_identity_pin integer DEFAULT 0 NOT NULL,
    spouse_last_name character varying,
    spouse_was_blind integer DEFAULT 0 NOT NULL,
    spouse_was_full_time_student integer DEFAULT 0 NOT NULL,
    spouse_was_on_visa integer DEFAULT 0 NOT NULL,
    state character varying,
    state_of_residence character varying,
    street_address character varying,
    timezone character varying,
    triage_source_id bigint,
    triage_source_type character varying,
    updated_at timestamp without time zone,
    viewed_at_capacity boolean DEFAULT false,
    visitor_id character varying,
    vita_partner_id bigint,
    vita_partner_name character varying,
    was_blind integer DEFAULT 0 NOT NULL,
    was_full_time_student integer DEFAULT 0 NOT NULL,
    was_on_visa integer DEFAULT 0 NOT NULL,
    widowed integer DEFAULT 0 NOT NULL,
    widowed_year character varying,
    zip_code character varying
);


--
-- Name: intakes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.intakes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intakes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.intakes_id_seq OWNED BY public.intakes.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id bigint NOT NULL,
    body text,
    client_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: organization_lead_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_lead_roles (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    vita_partner_id bigint NOT NULL
);


--
-- Name: organization_lead_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_lead_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_lead_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_lead_roles_id_seq OWNED BY public.organization_lead_roles.id;


--
-- Name: outbound_calls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outbound_calls (
    id bigint NOT NULL,
    client_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    from_phone_number character varying NOT NULL,
    note text,
    to_phone_number character varying NOT NULL,
    twilio_call_duration integer,
    twilio_sid character varying,
    twilio_status character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint
);


--
-- Name: outbound_calls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.outbound_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outbound_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.outbound_calls_id_seq OWNED BY public.outbound_calls.id;


--
-- Name: outgoing_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outgoing_emails (
    id bigint NOT NULL,
    body character varying NOT NULL,
    client_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    sent_at timestamp without time zone NOT NULL,
    subject character varying NOT NULL,
    "to" character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint
);


--
-- Name: outgoing_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.outgoing_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outgoing_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.outgoing_emails_id_seq OWNED BY public.outgoing_emails.id;


--
-- Name: outgoing_text_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outgoing_text_messages (
    id bigint NOT NULL,
    body character varying NOT NULL,
    client_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    sent_at timestamp without time zone NOT NULL,
    to_phone_number character varying NOT NULL,
    twilio_sid character varying,
    twilio_status character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint
);


--
-- Name: outgoing_text_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.outgoing_text_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outgoing_text_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.outgoing_text_messages_id_seq OWNED BY public.outgoing_text_messages.id;


--
-- Name: provider_scrapes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_scrapes (
    id bigint NOT NULL,
    archived_count integer DEFAULT 0 NOT NULL,
    changed_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_count integer DEFAULT 0 NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: provider_scrapes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.provider_scrapes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: provider_scrapes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.provider_scrapes_id_seq OWNED BY public.provider_scrapes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: signups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.signups (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    email_address character varying,
    name character varying,
    phone_number character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    zip_code character varying
);


--
-- Name: signups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.signups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: signups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.signups_id_seq OWNED BY public.signups.id;


--
-- Name: site_coordinator_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_coordinator_roles (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    vita_partner_id bigint NOT NULL
);


--
-- Name: site_coordinator_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_coordinator_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_coordinator_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_coordinator_roles_id_seq OWNED BY public.site_coordinator_roles.id;


--
-- Name: source_parameters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source_parameters (
    id bigint NOT NULL,
    code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    vita_partner_id bigint NOT NULL
);


--
-- Name: source_parameters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.source_parameters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: source_parameters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.source_parameters_id_seq OWNED BY public.source_parameters.id;


--
-- Name: stimulus_triages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stimulus_triages (
    id bigint NOT NULL,
    chose_to_file integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    filed_prior_years integer DEFAULT 0 NOT NULL,
    filed_recently integer DEFAULT 0 NOT NULL,
    need_to_correct integer DEFAULT 0 NOT NULL,
    need_to_file integer DEFAULT 0 NOT NULL,
    referrer character varying,
    source character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    visitor_id character varying
);


--
-- Name: stimulus_triages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stimulus_triages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stimulus_triages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stimulus_triages_id_seq OWNED BY public.stimulus_triages.id;


--
-- Name: system_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_notes (
    id bigint NOT NULL,
    body text,
    client_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint
);


--
-- Name: system_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_notes_id_seq OWNED BY public.system_notes.id;


--
-- Name: tax_returns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_returns (
    id bigint NOT NULL,
    assigned_user_id bigint,
    certification_level integer,
    client_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    is_hsa boolean,
    primary_signature character varying,
    primary_signed_at timestamp without time zone,
    primary_signed_ip inet,
    ready_for_prep_at timestamp without time zone,
    service_type integer DEFAULT 0,
    spouse_signature character varying,
    spouse_signed_at timestamp without time zone,
    spouse_signed_ip inet,
    status integer DEFAULT 100 NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    year integer NOT NULL
);


--
-- Name: tax_returns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tax_returns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tax_returns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tax_returns_id_seq OWNED BY public.tax_returns.id;


--
-- Name: team_member_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_member_roles (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    vita_partner_id bigint NOT NULL
);


--
-- Name: team_member_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_member_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_member_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_member_roles_id_seq OWNED BY public.team_member_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    active boolean,
    created_at timestamp(6) without time zone NOT NULL,
    current_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    email character varying NOT NULL,
    encrypted_access_token character varying,
    encrypted_access_token_iv character varying,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    failed_attempts integer DEFAULT 0 NOT NULL,
    invitation_accepted_at timestamp without time zone,
    invitation_created_at timestamp without time zone,
    invitation_limit integer,
    invitation_sent_at timestamp without time zone,
    invitation_token character varying,
    invitations_count integer DEFAULT 0,
    invited_by_id bigint,
    last_sign_in_at timestamp without time zone,
    last_sign_in_ip character varying,
    locked_at timestamp without time zone,
    name character varying,
    phone_number character varying,
    provider character varying,
    reset_password_sent_at timestamp without time zone,
    reset_password_token character varying,
    role_id bigint NOT NULL,
    role_type character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    suspended boolean,
    ticket_restriction character varying,
    timezone character varying DEFAULT 'America/New_York'::character varying NOT NULL,
    two_factor_auth_enabled boolean,
    uid character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    verified boolean,
    zendesk_user_id bigint
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vita_partner_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vita_partner_states (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    routing_fraction double precision DEFAULT 0.0 NOT NULL,
    state character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    vita_partner_id bigint NOT NULL
);


--
-- Name: vita_partner_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vita_partner_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vita_partner_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vita_partner_states_id_seq OWNED BY public.vita_partner_states.id;


--
-- Name: vita_partner_zip_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vita_partner_zip_codes (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    vita_partner_id bigint NOT NULL,
    zip_code character varying NOT NULL
);


--
-- Name: vita_partner_zip_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vita_partner_zip_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vita_partner_zip_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vita_partner_zip_codes_id_seq OWNED BY public.vita_partner_zip_codes.id;


--
-- Name: vita_partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vita_partners (
    id bigint NOT NULL,
    archived boolean DEFAULT false,
    coalition_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    logo_path character varying,
    name character varying NOT NULL,
    national_overflow_location boolean DEFAULT false,
    parent_organization_id bigint,
    updated_at timestamp(6) without time zone NOT NULL,
    weekly_capacity_limit integer
);


--
-- Name: vita_partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vita_partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vita_partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vita_partners_id_seq OWNED BY public.vita_partners.id;


--
-- Name: vita_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vita_providers (
    id bigint NOT NULL,
    appointment_info character varying,
    archived boolean DEFAULT false NOT NULL,
    coordinates public.geography(Point,4326),
    created_at timestamp without time zone,
    dates character varying,
    details character varying,
    hours character varying,
    irs_id character varying NOT NULL,
    languages character varying,
    last_scrape_id bigint,
    name character varying,
    updated_at timestamp without time zone
);


--
-- Name: vita_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vita_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vita_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vita_providers_id_seq OWNED BY public.vita_providers.id;


--
-- Name: access_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_logs ALTER COLUMN id SET DEFAULT nextval('public.access_logs_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: admin_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_roles ALTER COLUMN id SET DEFAULT nextval('public.admin_roles_id_seq'::regclass);


--
-- Name: anonymized_diy_intake_csv_extracts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anonymized_diy_intake_csv_extracts ALTER COLUMN id SET DEFAULT nextval('public.anonymized_diy_intake_csv_extracts_id_seq'::regclass);


--
-- Name: anonymized_intake_csv_extracts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anonymized_intake_csv_extracts ALTER COLUMN id SET DEFAULT nextval('public.anonymized_intake_csv_extracts_id_seq'::regclass);


--
-- Name: client_success_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_success_roles ALTER COLUMN id SET DEFAULT nextval('public.client_success_roles_id_seq'::regclass);


--
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients ALTER COLUMN id SET DEFAULT nextval('public.clients_id_seq'::regclass);


--
-- Name: coalition_lead_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coalition_lead_roles ALTER COLUMN id SET DEFAULT nextval('public.coalition_lead_roles_id_seq'::regclass);


--
-- Name: coalitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coalitions ALTER COLUMN id SET DEFAULT nextval('public.coalitions_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: dependents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependents ALTER COLUMN id SET DEFAULT nextval('public.dependents_id_seq'::regclass);


--
-- Name: diy_intakes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diy_intakes ALTER COLUMN id SET DEFAULT nextval('public.diy_intakes_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: documents_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents_requests ALTER COLUMN id SET DEFAULT nextval('public.documents_requests_id_seq'::regclass);


--
-- Name: greeter_coalition_join_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeter_coalition_join_records ALTER COLUMN id SET DEFAULT nextval('public.greeter_coalition_join_records_id_seq'::regclass);


--
-- Name: greeter_organization_join_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeter_organization_join_records ALTER COLUMN id SET DEFAULT nextval('public.greeter_organization_join_records_id_seq'::regclass);


--
-- Name: greeter_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeter_roles ALTER COLUMN id SET DEFAULT nextval('public.greeter_roles_id_seq'::regclass);


--
-- Name: incoming_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_emails ALTER COLUMN id SET DEFAULT nextval('public.incoming_emails_id_seq'::regclass);


--
-- Name: incoming_text_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_text_messages ALTER COLUMN id SET DEFAULT nextval('public.incoming_text_messages_id_seq'::regclass);


--
-- Name: intakes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intakes ALTER COLUMN id SET DEFAULT nextval('public.intakes_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: organization_lead_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_lead_roles ALTER COLUMN id SET DEFAULT nextval('public.organization_lead_roles_id_seq'::regclass);


--
-- Name: outbound_calls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbound_calls ALTER COLUMN id SET DEFAULT nextval('public.outbound_calls_id_seq'::regclass);


--
-- Name: outgoing_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoing_emails ALTER COLUMN id SET DEFAULT nextval('public.outgoing_emails_id_seq'::regclass);


--
-- Name: outgoing_text_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoing_text_messages ALTER COLUMN id SET DEFAULT nextval('public.outgoing_text_messages_id_seq'::regclass);


--
-- Name: provider_scrapes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_scrapes ALTER COLUMN id SET DEFAULT nextval('public.provider_scrapes_id_seq'::regclass);


--
-- Name: signups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signups ALTER COLUMN id SET DEFAULT nextval('public.signups_id_seq'::regclass);


--
-- Name: site_coordinator_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_coordinator_roles ALTER COLUMN id SET DEFAULT nextval('public.site_coordinator_roles_id_seq'::regclass);


--
-- Name: source_parameters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_parameters ALTER COLUMN id SET DEFAULT nextval('public.source_parameters_id_seq'::regclass);


--
-- Name: stimulus_triages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stimulus_triages ALTER COLUMN id SET DEFAULT nextval('public.stimulus_triages_id_seq'::regclass);


--
-- Name: system_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_notes ALTER COLUMN id SET DEFAULT nextval('public.system_notes_id_seq'::regclass);


--
-- Name: tax_returns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_returns ALTER COLUMN id SET DEFAULT nextval('public.tax_returns_id_seq'::regclass);


--
-- Name: team_member_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_roles ALTER COLUMN id SET DEFAULT nextval('public.team_member_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vita_partner_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_partner_states ALTER COLUMN id SET DEFAULT nextval('public.vita_partner_states_id_seq'::regclass);


--
-- Name: vita_partner_zip_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_partner_zip_codes ALTER COLUMN id SET DEFAULT nextval('public.vita_partner_zip_codes_id_seq'::regclass);


--
-- Name: vita_partners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_partners ALTER COLUMN id SET DEFAULT nextval('public.vita_partners_id_seq'::regclass);


--
-- Name: vita_providers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_providers ALTER COLUMN id SET DEFAULT nextval('public.vita_providers_id_seq'::regclass);


--
-- Name: access_logs access_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: admin_roles admin_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_roles
    ADD CONSTRAINT admin_roles_pkey PRIMARY KEY (id);


--
-- Name: anonymized_diy_intake_csv_extracts anonymized_diy_intake_csv_extracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anonymized_diy_intake_csv_extracts
    ADD CONSTRAINT anonymized_diy_intake_csv_extracts_pkey PRIMARY KEY (id);


--
-- Name: anonymized_intake_csv_extracts anonymized_intake_csv_extracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anonymized_intake_csv_extracts
    ADD CONSTRAINT anonymized_intake_csv_extracts_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: client_success_roles client_success_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_success_roles
    ADD CONSTRAINT client_success_roles_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: coalition_lead_roles coalition_lead_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coalition_lead_roles
    ADD CONSTRAINT coalition_lead_roles_pkey PRIMARY KEY (id);


--
-- Name: coalitions coalitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coalitions
    ADD CONSTRAINT coalitions_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: dependents dependents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependents
    ADD CONSTRAINT dependents_pkey PRIMARY KEY (id);


--
-- Name: diy_intakes diy_intakes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diy_intakes
    ADD CONSTRAINT diy_intakes_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: documents_requests documents_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents_requests
    ADD CONSTRAINT documents_requests_pkey PRIMARY KEY (id);


--
-- Name: greeter_coalition_join_records greeter_coalition_join_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeter_coalition_join_records
    ADD CONSTRAINT greeter_coalition_join_records_pkey PRIMARY KEY (id);


--
-- Name: greeter_organization_join_records greeter_organization_join_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeter_organization_join_records
    ADD CONSTRAINT greeter_organization_join_records_pkey PRIMARY KEY (id);


--
-- Name: greeter_roles greeter_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeter_roles
    ADD CONSTRAINT greeter_roles_pkey PRIMARY KEY (id);


--
-- Name: incoming_emails incoming_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_emails
    ADD CONSTRAINT incoming_emails_pkey PRIMARY KEY (id);


--
-- Name: incoming_text_messages incoming_text_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_text_messages
    ADD CONSTRAINT incoming_text_messages_pkey PRIMARY KEY (id);


--
-- Name: intakes intakes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intakes
    ADD CONSTRAINT intakes_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: organization_lead_roles organization_lead_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_lead_roles
    ADD CONSTRAINT organization_lead_roles_pkey PRIMARY KEY (id);


--
-- Name: outbound_calls outbound_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outbound_calls
    ADD CONSTRAINT outbound_calls_pkey PRIMARY KEY (id);


--
-- Name: outgoing_emails outgoing_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoing_emails
    ADD CONSTRAINT outgoing_emails_pkey PRIMARY KEY (id);


--
-- Name: outgoing_text_messages outgoing_text_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoing_text_messages
    ADD CONSTRAINT outgoing_text_messages_pkey PRIMARY KEY (id);


--
-- Name: provider_scrapes provider_scrapes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_scrapes
    ADD CONSTRAINT provider_scrapes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: signups signups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signups
    ADD CONSTRAINT signups_pkey PRIMARY KEY (id);


--
-- Name: site_coordinator_roles site_coordinator_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_coordinator_roles
    ADD CONSTRAINT site_coordinator_roles_pkey PRIMARY KEY (id);


--
-- Name: source_parameters source_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_parameters
    ADD CONSTRAINT source_parameters_pkey PRIMARY KEY (id);


--
-- Name: stimulus_triages stimulus_triages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stimulus_triages
    ADD CONSTRAINT stimulus_triages_pkey PRIMARY KEY (id);


--
-- Name: system_notes system_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_notes
    ADD CONSTRAINT system_notes_pkey PRIMARY KEY (id);


--
-- Name: tax_returns tax_returns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_returns
    ADD CONSTRAINT tax_returns_pkey PRIMARY KEY (id);


--
-- Name: team_member_roles team_member_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_roles
    ADD CONSTRAINT team_member_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vita_partner_states vita_partner_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_partner_states
    ADD CONSTRAINT vita_partner_states_pkey PRIMARY KEY (id);


--
-- Name: vita_partner_zip_codes vita_partner_zip_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_partner_zip_codes
    ADD CONSTRAINT vita_partner_zip_codes_pkey PRIMARY KEY (id);


--
-- Name: vita_partners vita_partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_partners
    ADD CONSTRAINT vita_partners_pkey PRIMARY KEY (id);


--
-- Name: vita_providers vita_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_providers
    ADD CONSTRAINT vita_providers_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: index_access_logs_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_logs_on_client_id ON public.access_logs USING btree (client_id);


--
-- Name: index_access_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_logs_on_user_id ON public.access_logs USING btree (user_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_clients_on_login_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_login_token ON public.clients USING btree (login_token);


--
-- Name: index_clients_on_vita_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_vita_partner_id ON public.clients USING btree (vita_partner_id);


--
-- Name: index_coalition_lead_roles_on_coalition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_coalition_lead_roles_on_coalition_id ON public.coalition_lead_roles USING btree (coalition_id);


--
-- Name: index_coalitions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_coalitions_on_name ON public.coalitions USING btree (name);


--
-- Name: index_dependents_on_intake_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dependents_on_intake_id ON public.dependents USING btree (intake_id);


--
-- Name: index_diy_intakes_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_diy_intakes_on_token ON public.diy_intakes USING btree (token);


--
-- Name: index_documents_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_client_id ON public.documents USING btree (client_id);


--
-- Name: index_documents_on_contact_record_type_and_contact_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_contact_record_type_and_contact_record_id ON public.documents USING btree (contact_record_type, contact_record_id);


--
-- Name: index_documents_on_documents_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_documents_request_id ON public.documents USING btree (documents_request_id);


--
-- Name: index_documents_on_intake_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_intake_id ON public.documents USING btree (intake_id);


--
-- Name: index_documents_on_tax_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_tax_return_id ON public.documents USING btree (tax_return_id);


--
-- Name: index_documents_on_uploaded_by_type_and_uploaded_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_uploaded_by_type_and_uploaded_by_id ON public.documents USING btree (uploaded_by_type, uploaded_by_id);


--
-- Name: index_documents_requests_on_intake_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_requests_on_intake_id ON public.documents_requests USING btree (intake_id);


--
-- Name: index_greeter_coalition_join_records_on_coalition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_greeter_coalition_join_records_on_coalition_id ON public.greeter_coalition_join_records USING btree (coalition_id);


--
-- Name: index_greeter_coalition_join_records_on_greeter_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_greeter_coalition_join_records_on_greeter_role_id ON public.greeter_coalition_join_records USING btree (greeter_role_id);


--
-- Name: index_greeter_organization_join_records_on_greeter_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_greeter_organization_join_records_on_greeter_role_id ON public.greeter_organization_join_records USING btree (greeter_role_id);


--
-- Name: index_greeter_organization_join_records_on_vita_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_greeter_organization_join_records_on_vita_partner_id ON public.greeter_organization_join_records USING btree (vita_partner_id);


--
-- Name: index_incoming_emails_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incoming_emails_on_client_id ON public.incoming_emails USING btree (client_id);


--
-- Name: index_incoming_text_messages_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incoming_text_messages_on_client_id ON public.incoming_text_messages USING btree (client_id);


--
-- Name: index_intakes_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intakes_on_client_id ON public.intakes USING btree (client_id);


--
-- Name: index_intakes_on_email_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intakes_on_email_address ON public.intakes USING btree (email_address);


--
-- Name: index_intakes_on_intake_ticket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intakes_on_intake_ticket_id ON public.intakes USING btree (intake_ticket_id);


--
-- Name: index_intakes_on_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intakes_on_phone_number ON public.intakes USING btree (phone_number);


--
-- Name: index_intakes_on_sms_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intakes_on_sms_phone_number ON public.intakes USING btree (sms_phone_number);


--
-- Name: index_intakes_on_triage_source_type_and_triage_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intakes_on_triage_source_type_and_triage_source_id ON public.intakes USING btree (triage_source_type, triage_source_id);


--
-- Name: index_intakes_on_vita_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intakes_on_vita_partner_id ON public.intakes USING btree (vita_partner_id);


--
-- Name: index_notes_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_client_id ON public.notes USING btree (client_id);


--
-- Name: index_notes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_user_id ON public.notes USING btree (user_id);


--
-- Name: index_organization_lead_roles_on_vita_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_lead_roles_on_vita_partner_id ON public.organization_lead_roles USING btree (vita_partner_id);


--
-- Name: index_outbound_calls_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outbound_calls_on_client_id ON public.outbound_calls USING btree (client_id);


--
-- Name: index_outbound_calls_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outbound_calls_on_user_id ON public.outbound_calls USING btree (user_id);


--
-- Name: index_outgoing_emails_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outgoing_emails_on_client_id ON public.outgoing_emails USING btree (client_id);


--
-- Name: index_outgoing_emails_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outgoing_emails_on_user_id ON public.outgoing_emails USING btree (user_id);


--
-- Name: index_outgoing_text_messages_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outgoing_text_messages_on_client_id ON public.outgoing_text_messages USING btree (client_id);


--
-- Name: index_outgoing_text_messages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outgoing_text_messages_on_user_id ON public.outgoing_text_messages USING btree (user_id);


--
-- Name: index_site_coordinator_roles_on_vita_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_site_coordinator_roles_on_vita_partner_id ON public.site_coordinator_roles USING btree (vita_partner_id);


--
-- Name: index_source_parameters_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_source_parameters_on_code ON public.source_parameters USING btree (code);


--
-- Name: index_source_parameters_on_vita_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_source_parameters_on_vita_partner_id ON public.source_parameters USING btree (vita_partner_id);


--
-- Name: index_system_notes_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_system_notes_on_client_id ON public.system_notes USING btree (client_id);


--
-- Name: index_system_notes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_system_notes_on_user_id ON public.system_notes USING btree (user_id);


--
-- Name: index_tax_returns_on_assigned_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tax_returns_on_assigned_user_id ON public.tax_returns USING btree (assigned_user_id);


--
-- Name: index_tax_returns_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tax_returns_on_client_id ON public.tax_returns USING btree (client_id);


--
-- Name: index_tax_returns_on_year_and_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tax_returns_on_year_and_client_id ON public.tax_returns USING btree (year, client_id);


--
-- Name: index_team_member_roles_on_vita_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_member_roles_on_vita_partner_id ON public.team_member_roles USING btree (vita_partner_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON public.users USING btree (invitation_token);


--
-- Name: index_users_on_invitations_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invitations_count ON public.users USING btree (invitations_count);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_id ON public.users USING btree (invited_by_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_role_type_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_role_type_and_role_id ON public.users USING btree (role_type, role_id);


--
-- Name: index_vita_partner_states_on_state_and_vita_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vita_partner_states_on_state_and_vita_partner_id ON public.vita_partner_states USING btree (state, vita_partner_id);


--
-- Name: index_vita_partner_states_on_vita_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vita_partner_states_on_vita_partner_id ON public.vita_partner_states USING btree (vita_partner_id);


--
-- Name: index_vita_partner_zip_codes_on_vita_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vita_partner_zip_codes_on_vita_partner_id ON public.vita_partner_zip_codes USING btree (vita_partner_id);


--
-- Name: index_vita_partner_zip_codes_on_zip_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vita_partner_zip_codes_on_zip_code ON public.vita_partner_zip_codes USING btree (zip_code);


--
-- Name: index_vita_partners_on_coalition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vita_partners_on_coalition_id ON public.vita_partners USING btree (coalition_id);


--
-- Name: index_vita_partners_on_parent_name_and_coalition; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vita_partners_on_parent_name_and_coalition ON public.vita_partners USING btree (parent_organization_id, name, coalition_id);


--
-- Name: index_vita_partners_on_parent_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vita_partners_on_parent_organization_id ON public.vita_partners USING btree (parent_organization_id);


--
-- Name: index_vita_providers_on_irs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vita_providers_on_irs_id ON public.vita_providers USING btree (irs_id);


--
-- Name: index_vita_providers_on_last_scrape_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vita_providers_on_last_scrape_id ON public.vita_providers USING btree (last_scrape_id);


--
-- Name: tax_returns fk_rails_06c6164b99; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_returns
    ADD CONSTRAINT fk_rails_06c6164b99 FOREIGN KEY (assigned_user_id) REFERENCES public.users(id);


--
-- Name: coalition_lead_roles fk_rails_1216e2929e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coalition_lead_roles
    ADD CONSTRAINT fk_rails_1216e2929e FOREIGN KEY (coalition_id) REFERENCES public.coalitions(id);


--
-- Name: incoming_text_messages fk_rails_15f2bddb7f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_text_messages
    ADD CONSTRAINT fk_rails_15f2bddb7f FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: vita_partner_zip_codes fk_rails_1813a9fc86; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_partner_zip_codes
    ADD CONSTRAINT fk_rails_1813a9fc86 FOREIGN KEY (vita_partner_id) REFERENCES public.vita_partners(id);


--
-- Name: greeter_organization_join_records fk_rails_188dc7fd3a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeter_organization_join_records
    ADD CONSTRAINT fk_rails_188dc7fd3a FOREIGN KEY (greeter_role_id) REFERENCES public.greeter_roles(id);


--
-- Name: documents fk_rails_2603945f4a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_2603945f4a FOREIGN KEY (documents_request_id) REFERENCES public.documents_requests(id);


--
-- Name: access_logs fk_rails_26726b0a1b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT fk_rails_26726b0a1b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: outgoing_emails fk_rails_2edac69bab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoing_emails
    ADD CONSTRAINT fk_rails_2edac69bab FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: documents fk_rails_2faf9571d0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_2faf9571d0 FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: greeter_coalition_join_records fk_rails_31082306b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeter_coalition_join_records
    ADD CONSTRAINT fk_rails_31082306b1 FOREIGN KEY (coalition_id) REFERENCES public.coalitions(id);


--
-- Name: notes fk_rails_4278b57a86; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_4278b57a86 FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: greeter_organization_join_records fk_rails_4298d98d35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeter_organization_join_records
    ADD CONSTRAINT fk_rails_4298d98d35 FOREIGN KEY (vita_partner_id) REFERENCES public.vita_partners(id);


--
-- Name: site_coordinator_roles fk_rails_4ed34b387d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_coordinator_roles
    ADD CONSTRAINT fk_rails_4ed34b387d FOREIGN KEY (vita_partner_id) REFERENCES public.vita_partners(id);


--
-- Name: system_notes fk_rails_5a01ea80fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_notes
    ADD CONSTRAINT fk_rails_5a01ea80fc FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: tax_returns fk_rails_5a5695111b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_returns
    ADD CONSTRAINT fk_rails_5a5695111b FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: outgoing_text_messages fk_rails_6349fcabf2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoing_text_messages
    ADD CONSTRAINT fk_rails_6349fcabf2 FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: vita_partners fk_rails_642b7cd16c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_partners
    ADD CONSTRAINT fk_rails_642b7cd16c FOREIGN KEY (coalition_id) REFERENCES public.coalitions(id);


--
-- Name: notes fk_rails_7f2323ad43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_7f2323ad43 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: clients fk_rails_a166493c5b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT fk_rails_a166493c5b FOREIGN KEY (vita_partner_id) REFERENCES public.vita_partners(id);


--
-- Name: outgoing_emails fk_rails_a2aaf7b94b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoing_emails
    ADD CONSTRAINT fk_rails_a2aaf7b94b FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: users fk_rails_ae14a5013f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_ae14a5013f FOREIGN KEY (invited_by_id) REFERENCES public.users(id);


--
-- Name: intakes fk_rails_b45bec770a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intakes
    ADD CONSTRAINT fk_rails_b45bec770a FOREIGN KEY (vita_partner_id) REFERENCES public.vita_partners(id);


--
-- Name: source_parameters fk_rails_b5ef596b48; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_parameters
    ADD CONSTRAINT fk_rails_b5ef596b48 FOREIGN KEY (vita_partner_id) REFERENCES public.vita_partners(id);


--
-- Name: greeter_coalition_join_records fk_rails_b9ebe604ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeter_coalition_join_records
    ADD CONSTRAINT fk_rails_b9ebe604ff FOREIGN KEY (greeter_role_id) REFERENCES public.greeter_roles(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: documents_requests fk_rails_ca1a6a7038; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents_requests
    ADD CONSTRAINT fk_rails_ca1a6a7038 FOREIGN KEY (intake_id) REFERENCES public.intakes(id);


--
-- Name: system_notes fk_rails_caf5ef89a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_notes
    ADD CONSTRAINT fk_rails_caf5ef89a2 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: organization_lead_roles fk_rails_ce45c5fe5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_lead_roles
    ADD CONSTRAINT fk_rails_ce45c5fe5c FOREIGN KEY (vita_partner_id) REFERENCES public.vita_partners(id);


--
-- Name: team_member_roles fk_rails_dd40ec58d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member_roles
    ADD CONSTRAINT fk_rails_dd40ec58d6 FOREIGN KEY (vita_partner_id) REFERENCES public.vita_partners(id);


--
-- Name: vita_partner_states fk_rails_ef239fcf13; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_partner_states
    ADD CONSTRAINT fk_rails_ef239fcf13 FOREIGN KEY (vita_partner_id) REFERENCES public.vita_partners(id);


--
-- Name: documents fk_rails_f760c9392d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_f760c9392d FOREIGN KEY (tax_return_id) REFERENCES public.tax_returns(id);


--
-- Name: access_logs fk_rails_f787442356; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT fk_rails_f787442356 FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- Name: vita_providers fk_rails_f91f9d04c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vita_providers
    ADD CONSTRAINT fk_rails_f91f9d04c3 FOREIGN KEY (last_scrape_id) REFERENCES public.provider_scrapes(id);


--
-- Name: outgoing_text_messages fk_rails_faf89c4278; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoing_text_messages
    ADD CONSTRAINT fk_rails_faf89c4278 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20191121004058'),
('20191121212945'),
('20191126212443'),
('20191126223956'),
('20191126224720'),
('20191127010918'),
('20191206192452'),
('20191213172404'),
('20191213185516'),
('20191220190731'),
('20200103194556'),
('20200103225859'),
('20200109175634'),
('20200109191316'),
('20200109223501'),
('20200109223512'),
('20200109223519'),
('20200122172508'),
('20200127224616'),
('20200128235924'),
('20200129183408'),
('20200130222437'),
('20200203215746'),
('20200204192916'),
('20200205003011'),
('20200206185608'),
('20200206191113'),
('20200206200449'),
('20200208170811'),
('20200208201855'),
('20200208203942'),
('20200208210650'),
('20200211182037'),
('20200211213645'),
('20200211233548'),
('20200211234425'),
('20200213192025'),
('20200213213234'),
('20200214215433'),
('20200218220540'),
('20200219234929'),
('20200220010211'),
('20200220225021'),
('20200220235309'),
('20200220235923'),
('20200221182648'),
('20200224235429'),
('20200226004131'),
('20200310224309'),
('20200312204231'),
('20200317173416'),
('20200321232039'),
('20200322010223'),
('20200322023004'),
('20200325225523'),
('20200331211739'),
('20200401211830'),
('20200407215425'),
('20200409203221'),
('20200409211248'),
('20200409231636'),
('20200410000131'),
('20200410213236'),
('20200415152456'),
('20200415184824'),
('20200417233703'),
('20200420205919'),
('20200421213952'),
('20200422181839'),
('20200428153517'),
('20200428220200'),
('20200429190910'),
('20200430175300'),
('20200504184255'),
('20200505214308'),
('20200505214753'),
('20200506005451'),
('20200506133753'),
('20200511181343'),
('20200512152806'),
('20200512205301'),
('20200512210214'),
('20200513160951'),
('20200514185642'),
('20200514214915'),
('20200519230707'),
('20200521084711'),
('20200521190628'),
('20200522093842'),
('20200523213434'),
('20200523233410'),
('20200523235516'),
('20200526164047'),
('20200527180219'),
('20200609145453'),
('20200610005807'),
('20200610203523'),
('20200610212912'),
('20200612170554'),
('20200617153218'),
('20200622180406'),
('20200630200820'),
('20200701223646'),
('20200706180321'),
('20200708121947'),
('20200708162728'),
('20200708190005'),
('20200710002316'),
('20200810181642'),
('20200810182819'),
('20200813185348'),
('20200817164441'),
('20200818171739'),
('20200826222452'),
('20200901231821'),
('20200902205739'),
('20200902221616'),
('20200903182626'),
('20200904175723'),
('20200908192228'),
('20200909013619'),
('20200909020442'),
('20200909172020'),
('20200910210703'),
('20200915224851'),
('20200916160314'),
('20200917042818'),
('20200924041919'),
('20200924042414'),
('20200924061736'),
('20200926201736'),
('20200926213358'),
('20200930092255'),
('20201001182401'),
('20201001184841'),
('20201001191542'),
('20201001221043'),
('20201006221136'),
('20201007194135'),
('20201008190415'),
('20201016195233'),
('20201019223124'),
('20201021160311'),
('20201022225306'),
('20201023203045'),
('20201026191626'),
('20201027215509'),
('20201029212035'),
('20201104232714'),
('20201106174103'),
('20201110191815'),
('20201110211437'),
('20201123144557'),
('20201130215059'),
('20201201204334'),
('20201202004742'),
('20201203233201'),
('20201207193859'),
('20201208193021'),
('20201209223919'),
('20201210181523'),
('20201210205143'),
('20201210225714'),
('20201210232524'),
('20201214184717'),
('20201214232037'),
('20201216012857'),
('20201217162102'),
('20201217162858'),
('20201217174546'),
('20201218172751'),
('20201218214947'),
('20201218232809'),
('20201220015616'),
('20201221034618'),
('20201222144009'),
('20201222165105'),
('20201222173607'),
('20201222174316'),
('20201222235548'),
('20201223164041'),
('20201223171455'),
('20201223232203'),
('20210104224344'),
('20210105011809'),
('20210105224857'),
('20210106164220'),
('20210106164804'),
('20210106173714'),
('20210106214432'),
('20210107220645'),
('20210108003707'),
('20210108164216'),
('20210108180823'),
('20210111192742'),
('20210112165258'),
('20210112185854'),
('20210112193119'),
('20210113173733'),
('20210114010352'),
('20210115165125'),
('20210120155211'),
('20210120184610'),
('20210120220654'),
('20210121185003'),
('20210122155255'),
('20210122191853'),
('20210125182944'),
('20210126162027'),
('20210126212403'),
('20210128003203'),
('20210128164534'),
('20210128170810'),
('20210128180337');


