# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_28_180337) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "access_logs", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.inet "ip_address"
    t.datetime "updated_at", precision: 6, null: false
    t.string "user_agent", null: false
    t.bigint "user_id", null: false
    t.index ["client_id"], name: "index_access_logs_on_client_id"
    t.index ["user_id"], name: "index_access_logs_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_roles", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "anonymized_diy_intake_csv_extracts", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.integer "record_count"
    t.datetime "run_at"
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "anonymized_intake_csv_extracts", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.integer "record_count"
    t.datetime "run_at"
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "client_success_roles", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "clients", force: :cascade do |t|
    t.datetime "attention_needed_since"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "current_sign_in_at"
    t.inet "current_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_incoming_interaction_at"
    t.datetime "last_interaction_at"
    t.datetime "last_sign_in_at"
    t.inet "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "login_requested_at"
    t.string "login_token"
    t.integer "routing_method"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "vita_partner_id"
    t.index ["login_token"], name: "index_clients_on_login_token"
    t.index ["vita_partner_id"], name: "index_clients_on_vita_partner_id"
  end

  create_table "coalition_lead_roles", force: :cascade do |t|
    t.bigint "coalition_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["coalition_id"], name: "index_coalition_lead_roles_on_coalition_id"
  end

  create_table "coalitions", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.string "name", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_coalitions_on_name", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at"
    t.datetime "failed_at"
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at"
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "dependents", force: :cascade do |t|
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.integer "disabled", default: 0, null: false
    t.string "first_name"
    t.bigint "intake_id", null: false
    t.string "last_name"
    t.integer "months_in_home"
    t.integer "north_american_resident", default: 0, null: false
    t.integer "on_visa", default: 0, null: false
    t.string "relationship"
    t.datetime "updated_at", null: false
    t.integer "was_married", default: 0, null: false
    t.integer "was_student", default: 0, null: false
    t.index ["intake_id"], name: "index_dependents_on_intake_id"
  end

  create_table "diy_intakes", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.string "email_address"
    t.string "locale"
    t.string "preferred_name"
    t.string "referrer"
    t.bigint "requester_id"
    t.string "source"
    t.string "state_of_residence"
    t.bigint "ticket_id"
    t.string "token"
    t.datetime "updated_at", precision: 6, null: false
    t.string "visitor_id"
    t.index ["token"], name: "index_diy_intakes_on_token", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "client_id"
    t.bigint "contact_record_id"
    t.string "contact_record_type"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "document_type", default: "Other", null: false
    t.bigint "documents_request_id"
    t.bigint "intake_id"
    t.bigint "tax_return_id"
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_id"
    t.string "uploaded_by_type"
    t.bigint "zendesk_ticket_id"
    t.index ["client_id"], name: "index_documents_on_client_id"
    t.index ["contact_record_type", "contact_record_id"], name: "index_documents_on_contact_record_type_and_contact_record_id"
    t.index ["documents_request_id"], name: "index_documents_on_documents_request_id"
    t.index ["intake_id"], name: "index_documents_on_intake_id"
    t.index ["tax_return_id"], name: "index_documents_on_tax_return_id"
    t.index ["uploaded_by_type", "uploaded_by_id"], name: "index_documents_on_uploaded_by_type_and_uploaded_by_id"
  end

  create_table "documents_requests", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.bigint "intake_id"
    t.datetime "updated_at", precision: 6, null: false
    t.index ["intake_id"], name: "index_documents_requests_on_intake_id"
  end

  create_table "greeter_coalition_join_records", force: :cascade do |t|
    t.bigint "coalition_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.bigint "greeter_role_id", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["coalition_id"], name: "index_greeter_coalition_join_records_on_coalition_id"
    t.index ["greeter_role_id"], name: "index_greeter_coalition_join_records_on_greeter_role_id"
  end

  create_table "greeter_organization_join_records", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.bigint "greeter_role_id", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "vita_partner_id", null: false
    t.index ["greeter_role_id"], name: "index_greeter_organization_join_records_on_greeter_role_id"
    t.index ["vita_partner_id"], name: "index_greeter_organization_join_records_on_vita_partner_id"
  end

  create_table "greeter_roles", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "incoming_emails", force: :cascade do |t|
    t.integer "attachment_count"
    t.string "body_html"
    t.string "body_plain", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.string "from", null: false
    t.string "message_id"
    t.string "received"
    t.datetime "received_at", null: false
    t.string "recipient", null: false
    t.string "sender", null: false
    t.string "stripped_html"
    t.string "stripped_signature"
    t.string "stripped_text"
    t.string "subject"
    t.string "to", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "user_agent"
    t.index ["client_id"], name: "index_incoming_emails_on_client_id"
  end

  create_table "incoming_text_messages", force: :cascade do |t|
    t.string "body"
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.string "from_phone_number", null: false
    t.datetime "received_at", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_incoming_text_messages_on_client_id"
  end

  create_table "intakes", force: :cascade do |t|
    t.string "additional_info"
    t.integer "adopted_child", default: 0, null: false
    t.integer "already_applied_for_stimulus", default: 0, null: false
    t.integer "already_filed", default: 0, null: false
    t.boolean "anonymous", default: false, null: false
    t.integer "balance_pay_from_bank", default: 0, null: false
    t.integer "bank_account_type", default: 0, null: false
    t.integer "bought_energy_efficient_items"
    t.integer "bought_health_insurance", default: 0, null: false
    t.string "city"
    t.integer "claimed_by_another", default: 0, null: false
    t.bigint "client_id"
    t.datetime "completed_at"
    t.boolean "completed_intake_sent_to_zendesk"
    t.datetime "completed_yes_no_questions_at"
    t.boolean "continued_at_capacity", default: false
    t.datetime "created_at"
    t.integer "demographic_disability", default: 0, null: false
    t.integer "demographic_english_conversation", default: 0, null: false
    t.integer "demographic_english_reading", default: 0, null: false
    t.boolean "demographic_primary_american_indian_alaska_native"
    t.boolean "demographic_primary_asian"
    t.boolean "demographic_primary_black_african_american"
    t.integer "demographic_primary_ethnicity", default: 0, null: false
    t.boolean "demographic_primary_native_hawaiian_pacific_islander"
    t.boolean "demographic_primary_prefer_not_to_answer_race"
    t.boolean "demographic_primary_white"
    t.integer "demographic_questions_opt_in", default: 0, null: false
    t.boolean "demographic_spouse_american_indian_alaska_native"
    t.boolean "demographic_spouse_asian"
    t.boolean "demographic_spouse_black_african_american"
    t.integer "demographic_spouse_ethnicity", default: 0, null: false
    t.boolean "demographic_spouse_native_hawaiian_pacific_islander"
    t.boolean "demographic_spouse_prefer_not_to_answer_race"
    t.boolean "demographic_spouse_white"
    t.integer "demographic_veteran", default: 0, null: false
    t.integer "divorced", default: 0, null: false
    t.string "divorced_year"
    t.boolean "eip_only"
    t.string "email_address"
    t.integer "email_notification_opt_in", default: 0, null: false
    t.string "encrypted_bank_account_number"
    t.string "encrypted_bank_account_number_iv"
    t.string "encrypted_bank_name"
    t.string "encrypted_bank_name_iv"
    t.string "encrypted_bank_routing_number"
    t.string "encrypted_bank_routing_number_iv"
    t.string "encrypted_primary_last_four_ssn"
    t.string "encrypted_primary_last_four_ssn_iv"
    t.string "encrypted_spouse_last_four_ssn"
    t.string "encrypted_spouse_last_four_ssn_iv"
    t.integer "ever_married", default: 0, null: false
    t.string "feedback"
    t.integer "feeling_about_taxes", default: 0, null: false
    t.integer "filing_for_stimulus", default: 0, null: false
    t.integer "filing_joint", default: 0, null: false
    t.string "final_info"
    t.integer "had_asset_sale_income", default: 0, null: false
    t.integer "had_debt_forgiven", default: 0, null: false
    t.integer "had_dependents", default: 0, null: false
    t.integer "had_disability", default: 0, null: false
    t.integer "had_disability_income", default: 0, null: false
    t.integer "had_disaster_loss", default: 0, null: false
    t.integer "had_farm_income", default: 0, null: false
    t.integer "had_gambling_income", default: 0, null: false
    t.integer "had_hsa", default: 0, null: false
    t.integer "had_interest_income", default: 0, null: false
    t.integer "had_local_tax_refund", default: 0, null: false
    t.integer "had_other_income", default: 0, null: false
    t.integer "had_rental_income", default: 0, null: false
    t.integer "had_retirement_income", default: 0, null: false
    t.integer "had_self_employment_income", default: 0, null: false
    t.integer "had_social_security_income", default: 0, null: false
    t.integer "had_social_security_or_retirement", default: 0, null: false
    t.integer "had_student_in_family", default: 0, null: false
    t.integer "had_tax_credit_disallowed", default: 0, null: false
    t.integer "had_tips", default: 0, null: false
    t.integer "had_unemployment_income", default: 0, null: false
    t.integer "had_wages", default: 0, null: false
    t.boolean "has_enqueued_ticket_creation", default: false
    t.integer "income_over_limit", default: 0, null: false
    t.boolean "intake_pdf_sent_to_zendesk", default: false, null: false
    t.bigint "intake_ticket_id"
    t.bigint "intake_ticket_requester_id"
    t.string "interview_timing_preference"
    t.integer "issued_identity_pin", default: 0, null: false
    t.integer "job_count"
    t.integer "lived_with_spouse", default: 0, null: false
    t.string "locale"
    t.integer "made_estimated_tax_payments", default: 0, null: false
    t.integer "married", default: 0, null: false
    t.integer "multiple_states", default: 0, null: false
    t.integer "needs_help_2016", default: 0, null: false
    t.integer "needs_help_2017", default: 0, null: false
    t.integer "needs_help_2018", default: 0, null: false
    t.integer "needs_help_2019", default: 0, null: false
    t.integer "needs_help_2020", default: 0, null: false
    t.integer "no_eligibility_checks_apply", default: 0, null: false
    t.integer "no_ssn", default: 0, null: false
    t.string "other_income_types"
    t.integer "paid_alimony", default: 0, null: false
    t.integer "paid_charitable_contributions", default: 0, null: false
    t.integer "paid_dependent_care", default: 0, null: false
    t.integer "paid_local_tax", default: 0, null: false
    t.integer "paid_medical_expenses", default: 0, null: false
    t.integer "paid_mortgage_interest", default: 0, null: false
    t.integer "paid_retirement_contributions", default: 0, null: false
    t.integer "paid_school_supplies", default: 0, null: false
    t.integer "paid_student_loan_interest", default: 0, null: false
    t.string "phone_number"
    t.integer "phone_number_can_receive_texts", default: 0, null: false
    t.string "preferred_interview_language"
    t.string "preferred_name"
    t.date "primary_birth_date"
    t.integer "primary_consented_to_service", default: 0, null: false
    t.datetime "primary_consented_to_service_at"
    t.inet "primary_consented_to_service_ip"
    t.string "primary_first_name"
    t.integer "primary_intake_id"
    t.string "primary_last_name"
    t.integer "received_alimony", default: 0, null: false
    t.integer "received_homebuyer_credit", default: 0, null: false
    t.integer "received_irs_letter", default: 0, null: false
    t.string "referrer"
    t.integer "refund_payment_method", default: 0, null: false
    t.integer "reported_asset_sale_loss", default: 0, null: false
    t.integer "reported_self_employment_loss", default: 0, null: false
    t.string "requested_docs_token"
    t.datetime "requested_docs_token_created_at"
    t.datetime "routed_at"
    t.string "routing_criteria"
    t.string "routing_value"
    t.integer "satisfaction_face", default: 0, null: false
    t.integer "savings_purchase_bond", default: 0, null: false
    t.integer "savings_split_refund", default: 0, null: false
    t.integer "separated", default: 0, null: false
    t.string "separated_year"
    t.integer "signature_method", default: 0, null: false
    t.integer "sms_notification_opt_in", default: 0, null: false
    t.string "sms_phone_number"
    t.integer "sold_a_home", default: 0, null: false
    t.integer "sold_assets", default: 0, null: false
    t.string "source"
    t.string "spouse_auth_token"
    t.date "spouse_birth_date"
    t.integer "spouse_consented_to_service", default: 0, null: false
    t.datetime "spouse_consented_to_service_at"
    t.inet "spouse_consented_to_service_ip"
    t.string "spouse_email_address"
    t.string "spouse_first_name"
    t.integer "spouse_had_disability", default: 0, null: false
    t.integer "spouse_issued_identity_pin", default: 0, null: false
    t.string "spouse_last_name"
    t.integer "spouse_was_blind", default: 0, null: false
    t.integer "spouse_was_full_time_student", default: 0, null: false
    t.integer "spouse_was_on_visa", default: 0, null: false
    t.string "state"
    t.string "state_of_residence"
    t.string "street_address"
    t.string "timezone"
    t.bigint "triage_source_id"
    t.string "triage_source_type"
    t.datetime "updated_at"
    t.boolean "viewed_at_capacity", default: false
    t.string "visitor_id", null: false
    t.bigint "vita_partner_id"
    t.string "vita_partner_name"
    t.integer "was_blind", default: 0, null: false
    t.integer "was_full_time_student", default: 0, null: false
    t.integer "was_on_visa", default: 0, null: false
    t.integer "widowed", default: 0, null: false
    t.string "widowed_year"
    t.string "zip_code"
    t.index ["client_id"], name: "index_intakes_on_client_id"
    t.index ["email_address"], name: "index_intakes_on_email_address"
    t.index ["intake_ticket_id"], name: "index_intakes_on_intake_ticket_id"
    t.index ["phone_number"], name: "index_intakes_on_phone_number"
    t.index ["sms_phone_number"], name: "index_intakes_on_sms_phone_number"
    t.index ["triage_source_type", "triage_source_id"], name: "index_intakes_on_triage_source_type_and_triage_source_id"
    t.index ["vita_partner_id"], name: "index_intakes_on_vita_partner_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "body"
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["client_id"], name: "index_notes_on_client_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "organization_lead_roles", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "vita_partner_id", null: false
    t.index ["vita_partner_id"], name: "index_organization_lead_roles_on_vita_partner_id"
  end

  create_table "outbound_calls", force: :cascade do |t|
    t.bigint "client_id"
    t.datetime "created_at", precision: 6, null: false
    t.string "from_phone_number", null: false
    t.text "note"
    t.string "to_phone_number", null: false
    t.integer "twilio_call_duration"
    t.string "twilio_sid"
    t.string "twilio_status"
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["client_id"], name: "index_outbound_calls_on_client_id"
    t.index ["user_id"], name: "index_outbound_calls_on_user_id"
  end

  create_table "outgoing_emails", force: :cascade do |t|
    t.string "body", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "sent_at", null: false
    t.string "subject", null: false
    t.string "to", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["client_id"], name: "index_outgoing_emails_on_client_id"
    t.index ["user_id"], name: "index_outgoing_emails_on_user_id"
  end

  create_table "outgoing_text_messages", force: :cascade do |t|
    t.string "body", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "sent_at", null: false
    t.string "to_phone_number", null: false
    t.string "twilio_sid"
    t.string "twilio_status"
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["client_id"], name: "index_outgoing_text_messages_on_client_id"
    t.index ["user_id"], name: "index_outgoing_text_messages_on_user_id"
  end

  create_table "provider_scrapes", force: :cascade do |t|
    t.integer "archived_count", default: 0, null: false
    t.integer "changed_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "created_count", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "signups", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.string "email_address"
    t.string "name"
    t.string "phone_number"
    t.datetime "updated_at", precision: 6, null: false
    t.string "zip_code"
  end

  create_table "site_coordinator_roles", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "vita_partner_id", null: false
    t.index ["vita_partner_id"], name: "index_site_coordinator_roles_on_vita_partner_id"
  end

  create_table "source_parameters", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "vita_partner_id", null: false
    t.index ["code"], name: "index_source_parameters_on_code", unique: true
    t.index ["vita_partner_id"], name: "index_source_parameters_on_vita_partner_id"
  end

  create_table "stimulus_triages", force: :cascade do |t|
    t.integer "chose_to_file", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.integer "filed_prior_years", default: 0, null: false
    t.integer "filed_recently", default: 0, null: false
    t.integer "need_to_correct", default: 0, null: false
    t.integer "need_to_file", default: 0, null: false
    t.string "referrer"
    t.string "source"
    t.datetime "updated_at", precision: 6, null: false
    t.string "visitor_id"
  end

  create_table "system_notes", force: :cascade do |t|
    t.text "body"
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["client_id"], name: "index_system_notes_on_client_id"
    t.index ["user_id"], name: "index_system_notes_on_user_id"
  end

  create_table "tax_returns", force: :cascade do |t|
    t.bigint "assigned_user_id"
    t.integer "certification_level"
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.boolean "is_hsa"
    t.string "primary_signature"
    t.datetime "primary_signed_at"
    t.inet "primary_signed_ip"
    t.datetime "ready_for_prep_at"
    t.integer "service_type", default: 0
    t.string "spouse_signature"
    t.datetime "spouse_signed_at"
    t.inet "spouse_signed_ip"
    t.integer "status", default: 100, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "year", null: false
    t.index ["assigned_user_id"], name: "index_tax_returns_on_assigned_user_id"
    t.index ["client_id"], name: "index_tax_returns_on_client_id"
    t.index ["year", "client_id"], name: "index_tax_returns_on_year_and_client_id", unique: true
  end

  create_table "team_member_roles", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "vita_partner_id", null: false
    t.index ["vita_partner_id"], name: "index_team_member_roles_on_vita_partner_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", null: false
    t.string "encrypted_access_token"
    t.string "encrypted_access_token_iv"
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_created_at"
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at"
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.bigint "invited_by_id"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name"
    t.string "phone_number"
    t.string "provider"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.bigint "role_id", null: false
    t.string "role_type", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.boolean "suspended"
    t.string "ticket_restriction"
    t.string "timezone", default: "America/New_York", null: false
    t.boolean "two_factor_auth_enabled"
    t.string "uid"
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "verified"
    t.bigint "zendesk_user_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_type", "role_id"], name: "index_users_on_role_type_and_role_id", unique: true
  end

  create_table "vita_partner_states", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.float "routing_fraction", default: 0.0, null: false
    t.string "state", null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "vita_partner_id", null: false
    t.index ["state", "vita_partner_id"], name: "index_vita_partner_states_on_state_and_vita_partner_id", unique: true
    t.index ["vita_partner_id"], name: "index_vita_partner_states_on_vita_partner_id"
  end

  create_table "vita_partner_zip_codes", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "vita_partner_id", null: false
    t.string "zip_code", null: false
    t.index ["vita_partner_id"], name: "index_vita_partner_zip_codes_on_vita_partner_id"
    t.index ["zip_code"], name: "index_vita_partner_zip_codes_on_zip_code", unique: true
  end

  create_table "vita_partners", force: :cascade do |t|
    t.boolean "archived", default: false
    t.bigint "coalition_id"
    t.datetime "created_at", precision: 6, null: false
    t.string "logo_path"
    t.string "name", null: false
    t.boolean "national_overflow_location", default: false
    t.bigint "parent_organization_id"
    t.datetime "updated_at", precision: 6, null: false
    t.integer "weekly_capacity_limit"
    t.index ["coalition_id"], name: "index_vita_partners_on_coalition_id"
    t.index ["parent_organization_id", "name", "coalition_id"], name: "index_vita_partners_on_parent_name_and_coalition", unique: true
    t.index ["parent_organization_id"], name: "index_vita_partners_on_parent_organization_id"
  end

  create_table "vita_providers", force: :cascade do |t|
    t.string "appointment_info"
    t.boolean "archived", default: false, null: false
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at"
    t.string "dates"
    t.string "details"
    t.string "hours"
    t.string "irs_id", null: false
    t.string "languages"
    t.bigint "last_scrape_id"
    t.string "name"
    t.datetime "updated_at"
    t.index ["irs_id"], name: "index_vita_providers_on_irs_id", unique: true
    t.index ["last_scrape_id"], name: "index_vita_providers_on_last_scrape_id"
  end

  add_foreign_key "access_logs", "clients"
  add_foreign_key "access_logs", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "clients", "vita_partners"
  add_foreign_key "coalition_lead_roles", "coalitions"
  add_foreign_key "documents", "clients"
  add_foreign_key "documents", "documents_requests"
  add_foreign_key "documents", "tax_returns"
  add_foreign_key "documents_requests", "intakes"
  add_foreign_key "greeter_coalition_join_records", "coalitions"
  add_foreign_key "greeter_coalition_join_records", "greeter_roles"
  add_foreign_key "greeter_organization_join_records", "greeter_roles"
  add_foreign_key "greeter_organization_join_records", "vita_partners"
  add_foreign_key "incoming_text_messages", "clients"
  add_foreign_key "intakes", "vita_partners"
  add_foreign_key "notes", "clients"
  add_foreign_key "notes", "users"
  add_foreign_key "organization_lead_roles", "vita_partners"
  add_foreign_key "outgoing_emails", "clients"
  add_foreign_key "outgoing_emails", "users"
  add_foreign_key "outgoing_text_messages", "clients"
  add_foreign_key "outgoing_text_messages", "users"
  add_foreign_key "site_coordinator_roles", "vita_partners"
  add_foreign_key "source_parameters", "vita_partners"
  add_foreign_key "system_notes", "clients"
  add_foreign_key "system_notes", "users"
  add_foreign_key "tax_returns", "clients"
  add_foreign_key "tax_returns", "users", column: "assigned_user_id"
  add_foreign_key "team_member_roles", "vita_partners"
  add_foreign_key "users", "users", column: "invited_by_id"
  add_foreign_key "vita_partner_states", "vita_partners"
  add_foreign_key "vita_partner_zip_codes", "vita_partners"
  add_foreign_key "vita_partners", "coalitions"
  add_foreign_key "vita_providers", "provider_scrapes", column: "last_scrape_id"
end
