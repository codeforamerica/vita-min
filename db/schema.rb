# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_11_06_164646) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "abandoned_pre_consent_intakes", force: :cascade do |t|
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.string "intake_type"
    t.string "referrer"
    t.string "source"
    t.integer "triage_filing_frequency"
    t.integer "triage_filing_status"
    t.integer "triage_income_level"
    t.integer "triage_vita_income_ineligible"
    t.datetime "updated_at", null: false
    t.string "visitor_id"
  end

  create_table "accepted_tax_return_analytics", force: :cascade do |t|
    t.bigint "advance_ctc_amount_cents"
    t.datetime "created_at", null: false
    t.bigint "ctc_amount_cents"
    t.bigint "eip1_and_eip2_amount_cents"
    t.bigint "eip3_amount_cents"
    t.bigint "eip3_amount_received_cents"
    t.bigint "eitc_amount_cents"
    t.bigint "outstanding_ctc_amount_cents"
    t.bigint "outstanding_eip3_amount_cents"
    t.bigint "tax_return_id"
    t.bigint "total_refund_amount_cents"
    t.datetime "updated_at", null: false
    t.index ["tax_return_id"], name: "index_accepted_tax_return_analytics_on_tax_return_id"
  end

  create_table "access_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.inet "ip_address"
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent", null: false
    t.bigint "user_id", null: false
    t.index ["record_type", "record_id"], name: "index_access_logs_on_record_type_and_record_id"
    t.index ["user_id"], name: "index_access_logs_on_user_id"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.bigint "record_id"
    t.string "record_type"
    t.boolean "skip_usps_validation", default: false
    t.string "state"
    t.string "street_address"
    t.string "street_address2"
    t.datetime "updated_at", null: false
    t.string "urbanization"
    t.string "zip_code"
    t.index ["record_type", "record_id"], name: "index_addresses_on_record_type_and_record_id"
  end

  create_table "admin_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "engineer"
    t.datetime "updated_at", null: false
  end

  create_table "admin_toggles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.json "value"
    t.index ["user_id"], name: "index_admin_toggles_on_user_id"
  end

  create_table "analytics_events", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "event_type"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_analytics_events_on_client_id"
    t.index ["event_type", "client_id"], name: "index_analytics_events_on_event_type_and_client_id"
  end

  create_table "anonymized_diy_intake_csv_extracts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "record_count"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", null: false
  end

  create_table "anonymized_intake_csv_extracts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "record_count"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", null: false
  end

  create_table "archived_bank_accounts_2021", force: :cascade do |t|
    t.text "account_number"
    t.integer "account_type"
    t.bigint "archived_intakes_2021_id"
    t.string "bank_name"
    t.datetime "created_at", null: false
    t.string "hashed_account_number"
    t.string "hashed_routing_number"
    t.string "routing_number"
    t.datetime "updated_at", null: false
    t.index ["archived_intakes_2021_id"], name: "index_archived_bank_accounts_2021_on_archived_intakes_2021_id"
    t.index ["hashed_account_number"], name: "index_archived_bank_accounts_2021_on_hashed_account_number"
    t.index ["hashed_routing_number"], name: "index_archived_bank_accounts_2021_on_hashed_routing_number"
  end

  create_table "archived_dependents_2021", force: :cascade do |t|
    t.bigint "archived_intakes_2021_id", null: false
    t.date "birth_date", null: false
    t.integer "born_in_2020", default: 0, null: false
    t.integer "cant_be_claimed_by_other", default: 0, null: false
    t.integer "claim_anyway", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "creation_token"
    t.integer "disabled", default: 0, null: false
    t.integer "filed_joint_return", default: 0, null: false
    t.string "first_name"
    t.integer "full_time_student", default: 0, null: false
    t.integer "has_ip_pin", default: 0, null: false
    t.text "ip_pin"
    t.string "last_name"
    t.integer "lived_with_more_than_six_months", default: 0, null: false
    t.integer "meets_misc_qualifying_relative_requirements", default: 0, null: false
    t.string "middle_initial"
    t.integer "months_in_home"
    t.integer "no_ssn_atin", default: 0, null: false
    t.integer "north_american_resident", default: 0, null: false
    t.integer "on_visa", default: 0, null: false
    t.integer "passed_away_2020", default: 0, null: false
    t.integer "permanent_residence_with_client", default: 0, null: false
    t.integer "permanently_totally_disabled", default: 0, null: false
    t.integer "placed_for_adoption", default: 0, null: false
    t.integer "provided_over_half_own_support", default: 0, null: false
    t.string "relationship"
    t.datetime "soft_deleted_at", precision: nil
    t.text "ssn"
    t.string "suffix"
    t.integer "tin_type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "was_married", default: 0, null: false
    t.integer "was_student", default: 0, null: false
    t.index ["archived_intakes_2021_id"], name: "index_archived_dependents_2021_on_archived_intakes_2021_id"
    t.index ["creation_token"], name: "index_archived_dependents_2021_on_creation_token"
  end

  create_table "archived_intakes_2021", force: :cascade do |t|
    t.string "additional_info"
    t.integer "adopted_child", default: 0, null: false
    t.integer "already_applied_for_stimulus", default: 0, null: false
    t.integer "already_filed", default: 0, null: false
    t.integer "balance_pay_from_bank", default: 0, null: false
    t.text "bank_account_number"
    t.integer "bank_account_type", default: 0, null: false
    t.string "bank_name"
    t.string "bank_routing_number"
    t.integer "bought_energy_efficient_items"
    t.integer "bought_health_insurance", default: 0, null: false
    t.integer "cannot_claim_me_as_a_dependent", default: 0, null: false
    t.string "canonical_email_address"
    t.string "city"
    t.integer "claim_owed_stimulus_money", default: 0, null: false
    t.integer "claimed_by_another", default: 0, null: false
    t.bigint "client_id"
    t.datetime "completed_at", precision: nil
    t.datetime "completed_yes_no_questions_at", precision: nil
    t.integer "consented_to_legal", default: 0, null: false
    t.boolean "continued_at_capacity", default: false
    t.datetime "created_at", precision: nil
    t.string "current_step"
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
    t.integer "eip1_amount_received"
    t.integer "eip1_and_2_amount_received_confidence"
    t.integer "eip1_entry_method", default: 0, null: false
    t.integer "eip2_amount_received"
    t.integer "eip2_entry_method", default: 0, null: false
    t.boolean "eip_only"
    t.citext "email_address"
    t.datetime "email_address_verified_at", precision: nil
    t.string "email_domain"
    t.integer "email_notification_opt_in", default: 0, null: false
    t.integer "ever_married", default: 0, null: false
    t.integer "ever_owned_home", default: 0, null: false
    t.string "feedback"
    t.integer "feeling_about_taxes", default: 0, null: false
    t.integer "filed_2020", default: 0, null: false
    t.integer "filed_prior_tax_year", default: 0, null: false
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
    t.integer "has_primary_ip_pin", default: 0, null: false
    t.integer "has_spouse_ip_pin", default: 0, null: false
    t.string "hashed_primary_ssn"
    t.integer "income_over_limit", default: 0, null: false
    t.string "interview_timing_preference"
    t.integer "issued_identity_pin", default: 0, null: false
    t.integer "job_count"
    t.integer "lived_with_spouse", default: 0, null: false
    t.string "locale"
    t.integer "made_estimated_tax_payments", default: 0, null: false
    t.integer "married", default: 0, null: false
    t.integer "multiple_states", default: 0, null: false
    t.boolean "navigator_has_verified_client_identity"
    t.string "navigator_name"
    t.integer "needs_help_2016", default: 0, null: false
    t.integer "needs_help_2017", default: 0, null: false
    t.integer "needs_help_2018", default: 0, null: false
    t.integer "needs_help_2019", default: 0, null: false
    t.integer "needs_help_2020", default: 0, null: false
    t.datetime "needs_to_flush_searchable_data_set_at", precision: nil
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
    t.integer "primary_active_armed_forces", default: 0, null: false
    t.date "primary_birth_date"
    t.integer "primary_consented_to_service", default: 0, null: false
    t.datetime "primary_consented_to_service_at", precision: nil
    t.inet "primary_consented_to_service_ip"
    t.string "primary_first_name"
    t.text "primary_ip_pin"
    t.text "primary_last_four_ssn"
    t.string "primary_last_name"
    t.string "primary_middle_initial"
    t.integer "primary_prior_year_agi_amount"
    t.string "primary_prior_year_signature_pin"
    t.text "primary_signature_pin"
    t.datetime "primary_signature_pin_at", precision: nil
    t.text "primary_ssn"
    t.string "primary_suffix"
    t.integer "primary_tin_type"
    t.integer "received_alimony", default: 0, null: false
    t.integer "received_homebuyer_credit", default: 0, null: false
    t.integer "received_irs_letter", default: 0, null: false
    t.integer "received_stimulus_payment", default: 0, null: false
    t.string "referrer"
    t.integer "refund_payment_method", default: 0, null: false
    t.integer "reported_asset_sale_loss", default: 0, null: false
    t.integer "reported_self_employment_loss", default: 0, null: false
    t.string "requested_docs_token"
    t.datetime "requested_docs_token_created_at", precision: nil
    t.datetime "routed_at", precision: nil
    t.string "routing_criteria"
    t.string "routing_value"
    t.integer "satisfaction_face", default: 0, null: false
    t.integer "savings_purchase_bond", default: 0, null: false
    t.integer "savings_split_refund", default: 0, null: false
    t.tsvector "searchable_data"
    t.integer "separated", default: 0, null: false
    t.string "separated_year"
    t.integer "signature_method", default: 0, null: false
    t.integer "sms_notification_opt_in", default: 0, null: false
    t.string "sms_phone_number"
    t.datetime "sms_phone_number_verified_at", precision: nil
    t.integer "sold_a_home", default: 0, null: false
    t.integer "sold_assets", default: 0, null: false
    t.string "source"
    t.integer "spouse_active_armed_forces", default: 0
    t.string "spouse_auth_token"
    t.date "spouse_birth_date"
    t.integer "spouse_can_be_claimed_as_dependent", default: 0
    t.integer "spouse_consented_to_service", default: 0, null: false
    t.datetime "spouse_consented_to_service_at", precision: nil
    t.inet "spouse_consented_to_service_ip"
    t.citext "spouse_email_address"
    t.integer "spouse_filed_prior_tax_year", default: 0, null: false
    t.string "spouse_first_name"
    t.integer "spouse_had_disability", default: 0, null: false
    t.text "spouse_ip_pin"
    t.integer "spouse_issued_identity_pin", default: 0, null: false
    t.text "spouse_last_four_ssn"
    t.string "spouse_last_name"
    t.string "spouse_middle_initial"
    t.integer "spouse_prior_year_agi_amount"
    t.string "spouse_prior_year_signature_pin"
    t.text "spouse_signature_pin"
    t.datetime "spouse_signature_pin_at", precision: nil
    t.text "spouse_ssn"
    t.string "spouse_suffix"
    t.integer "spouse_tin_type"
    t.integer "spouse_was_blind", default: 0, null: false
    t.integer "spouse_was_full_time_student", default: 0, null: false
    t.integer "spouse_was_on_visa", default: 0, null: false
    t.string "state"
    t.string "state_of_residence"
    t.string "street_address"
    t.string "street_address2"
    t.string "timezone"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.boolean "use_primary_name_for_name_control", default: false
    t.boolean "viewed_at_capacity", default: false
    t.string "visitor_id"
    t.bigint "vita_partner_id"
    t.string "vita_partner_name"
    t.integer "wants_to_itemize", default: 0, null: false
    t.integer "was_blind", default: 0, null: false
    t.integer "was_full_time_student", default: 0, null: false
    t.integer "was_on_visa", default: 0, null: false
    t.integer "widowed", default: 0, null: false
    t.string "widowed_year"
    t.boolean "with_drivers_license_photo_id", default: false
    t.boolean "with_general_navigator", default: false
    t.boolean "with_incarcerated_navigator", default: false
    t.boolean "with_itin_taxpayer_id", default: false
    t.boolean "with_limited_english_navigator", default: false
    t.boolean "with_other_state_photo_id", default: false
    t.boolean "with_passport_photo_id", default: false
    t.boolean "with_social_security_taxpayer_id", default: false
    t.boolean "with_unhoused_navigator", default: false
    t.boolean "with_vita_approved_photo_id", default: false
    t.boolean "with_vita_approved_taxpayer_id", default: false
    t.string "zip_code"
    t.index ["canonical_email_address"], name: "index_arcint_2021_on_canonical_email_address"
    t.index ["client_id"], name: "index_arcint_2021_on_client_id"
    t.index ["completed_at"], name: "index_arcint_2021_on_completed_at", where: "(completed_at IS NOT NULL)"
    t.index ["email_address"], name: "index_arcint_2021_on_email_address"
    t.index ["email_domain"], name: "index_arcint_2021_on_email_domain"
    t.index ["needs_to_flush_searchable_data_set_at"], name: "index_arcint_2021_on_needs_to_flush_searchable_data_set_at", where: "(needs_to_flush_searchable_data_set_at IS NOT NULL)"
    t.index ["phone_number"], name: "index_arcint_2021_on_phone_number"
    t.index ["primary_birth_date", "primary_first_name", "primary_last_name"], name: "index_arcint_2021_on_probable_previous_year_intake_fields"
    t.index ["searchable_data"], name: "index_arcint_2021_on_searchable_data", using: :gin
    t.index ["sms_phone_number"], name: "index_arcint_2021_on_sms_phone_number"
    t.index ["spouse_email_address"], name: "index_arcint_2021_on_spouse_email_address"
    t.index ["type"], name: "index_arcint_2021_on_type"
    t.index ["vita_partner_id"], name: "index_arcint_2021_on_vita_partner_id"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.text "account_number"
    t.integer "account_type"
    t.string "bank_name"
    t.datetime "created_at", null: false
    t.string "hashed_account_number"
    t.bigint "intake_id"
    t.string "routing_number"
    t.datetime "updated_at", null: false
    t.index ["hashed_account_number"], name: "index_bank_accounts_on_hashed_account_number"
    t.index ["intake_id"], name: "index_bank_accounts_on_intake_id"
    t.index ["routing_number"], name: "index_bank_accounts_on_routing_number"
  end

  create_table "bulk_action_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "task_type", null: false
    t.bigint "tax_return_selection_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_return_selection_id"], name: "index_bulk_action_notifications_on_tax_return_selection_id"
  end

  create_table "bulk_client_message_outgoing_emails", force: :cascade do |t|
    t.bigint "bulk_client_message_id", null: false
    t.datetime "created_at", null: false
    t.bigint "outgoing_email_id", null: false
    t.datetime "updated_at", null: false
    t.index ["bulk_client_message_id"], name: "index_bcmoe_on_bulk_client_message_id"
    t.index ["outgoing_email_id"], name: "index_bcmoe_on_outgoing_email_id"
  end

  create_table "bulk_client_message_outgoing_text_messages", force: :cascade do |t|
    t.bigint "bulk_client_message_id", null: false
    t.datetime "created_at", null: false
    t.bigint "outgoing_text_message_id", null: false
    t.datetime "updated_at", null: false
    t.index ["bulk_client_message_id"], name: "index_bcmotm_on_bulk_client_message_id"
    t.index ["outgoing_text_message_id"], name: "index_bcmotm_on_outgoing_text_message_id"
  end

  create_table "bulk_client_messages", force: :cascade do |t|
    t.jsonb "cached_data", default: {}
    t.datetime "created_at", null: false
    t.string "send_only"
    t.bigint "tax_return_selection_id"
    t.datetime "updated_at", null: false
    t.index ["tax_return_selection_id"], name: "index_bcm_on_tax_return_selection_id"
  end

  create_table "bulk_client_notes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tax_return_selection_id"
    t.datetime "updated_at", null: false
    t.index ["tax_return_selection_id"], name: "index_bcn_on_tax_return_selection_id"
  end

  create_table "bulk_client_organization_updates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tax_return_selection_id"
    t.datetime "updated_at", null: false
    t.bigint "vita_partner_id", null: false
    t.index ["tax_return_selection_id"], name: "index_bcou_on_tax_return_selection_id"
    t.index ["vita_partner_id"], name: "index_bulk_client_organization_updates_on_vita_partner_id"
  end

  create_table "bulk_message_csvs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "status"
    t.bigint "tax_return_selection_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["tax_return_selection_id"], name: "index_bulk_message_csvs_on_tax_return_selection_id"
    t.index ["user_id"], name: "index_bulk_message_csvs_on_user_id"
  end

  create_table "bulk_signup_message_outgoing_message_statuses", force: :cascade do |t|
    t.bigint "bulk_signup_message_id", null: false
    t.bigint "outgoing_message_status_id", null: false
    t.index ["bulk_signup_message_id"], name: "index_bsmoms_on_bulk_signup_messages_id"
    t.index ["outgoing_message_status_id"], name: "index_bsmoms_on_outgoing_message_statuses_id"
  end

  create_table "bulk_signup_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "message", null: false
    t.integer "message_type", null: false
    t.bigint "signup_selection_id", null: false
    t.text "subject"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["signup_selection_id"], name: "index_bulk_signup_messages_on_signup_selection_id"
    t.index ["user_id"], name: "index_bulk_signup_messages_on_user_id"
  end

  create_table "bulk_tax_return_updates", force: :cascade do |t|
    t.bigint "assigned_user_id"
    t.datetime "created_at", null: false
    t.json "data"
    t.string "state"
    t.integer "status"
    t.bigint "tax_return_selection_id", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_user_id"], name: "index_btru_on_assigned_user_id"
    t.index ["tax_return_selection_id"], name: "index_btru_on_tax_return_selection_id"
  end

  create_table "client_success_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.datetime "attention_needed_since", precision: nil
    t.datetime "completion_survey_sent_at", precision: nil
    t.datetime "consented_to_service_at"
    t.datetime "created_at", null: false
    t.datetime "ctc_experience_survey_sent_at", precision: nil
    t.integer "ctc_experience_survey_variant"
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.integer "experience_survey", default: 0, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.integer "filterable_number_of_required_documents", default: 3
    t.integer "filterable_number_of_required_documents_uploaded", default: 0
    t.decimal "filterable_percentage_of_required_documents_uploaded", precision: 5, scale: 2, default: "0.0"
    t.integer "filterable_product_year"
    t.jsonb "filterable_tax_return_properties"
    t.datetime "first_unanswered_incoming_interaction_at", precision: nil
    t.datetime "flagged_at", precision: nil
    t.datetime "identity_verification_denied_at", precision: nil
    t.datetime "identity_verified_at", precision: nil
    t.datetime "in_progress_survey_sent_at", precision: nil
    t.datetime "last_13614c_update_at", precision: nil
    t.datetime "last_incoming_interaction_at", precision: nil
    t.datetime "last_internal_or_outgoing_interaction_at", precision: nil
    t.datetime "last_outgoing_communication_at", precision: nil
    t.datetime "last_seen_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.datetime "login_requested_at", precision: nil
    t.string "login_token"
    t.jsonb "message_tracker", default: {}
    t.datetime "needs_to_flush_filterable_properties_set_at"
    t.integer "previous_sessions_active_seconds"
    t.datetime "restricted_at", precision: nil
    t.integer "routing_method"
    t.integer "sign_in_count", default: 0, null: false
    t.integer "still_needs_help", default: 0, null: false
    t.datetime "triggered_still_needs_help_at", precision: nil
    t.datetime "updated_at", null: false
    t.bigint "vita_partner_id"
    t.index ["consented_to_service_at"], name: "index_clients_on_consented_to_service_at"
    t.index ["filterable_product_year", "filterable_percentage_of_required_documents_uploaded"], name: "index_clients_on_fpy_and_required_docs_uploaded", where: "(consented_to_service_at IS NOT NULL)"
    t.index ["filterable_product_year", "first_unanswered_incoming_interaction_at"], name: "index_clients_on_fpy_and_first_uii_at", where: "(consented_to_service_at IS NOT NULL)"
    t.index ["filterable_product_year", "in_progress_survey_sent_at"], name: "index_clients_on_fpy_and_in_progress_survey_sent_at", where: "(consented_to_service_at IS NOT NULL)"
    t.index ["filterable_product_year", "last_outgoing_communication_at"], name: "index_clients_on_fpy_and_last_outgoing_communication_at", where: "(consented_to_service_at IS NOT NULL)"
    t.index ["filterable_product_year", "updated_at"], name: "index_clients_on_fpy_and_updated_at", where: "(consented_to_service_at IS NOT NULL)"
    t.index ["filterable_tax_return_properties"], name: "index_clients_on_filterable_tax_return_properties", using: :gin
    t.index ["in_progress_survey_sent_at"], name: "index_clients_on_in_progress_survey_sent_at"
    t.index ["last_outgoing_communication_at"], name: "index_clients_on_last_outgoing_communication_at"
    t.index ["login_token"], name: "index_clients_on_login_token"
    t.index ["needs_to_flush_filterable_properties_set_at"], name: "index_clients_on_needs_to_flush_filterable_properties_set_at"
    t.index ["vita_partner_id"], name: "index_clients_on_vita_partner_id"
  end

  create_table "coalition_lead_roles", force: :cascade do |t|
    t.bigint "coalition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coalition_id"], name: "index_coalition_lead_roles_on_coalition_id"
  end

  create_table "coalitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.citext "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_coalitions_on_name", unique: true
  end

  create_table "consents", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "disclose_consented_at", precision: nil
    t.datetime "global_carryforward_consented_at", precision: nil
    t.inet "ip"
    t.datetime "relational_efin_consented_at", precision: nil
    t.datetime "updated_at", null: false
    t.datetime "use_consented_at", precision: nil
    t.string "user_agent"
    t.index ["client_id"], name: "index_consents_on_client_id"
  end

  create_table "ctc_signups", force: :cascade do |t|
    t.datetime "beta_email_sent_at", precision: nil
    t.datetime "created_at", null: false
    t.string "email_address"
    t.datetime "launch_announcement_sent_at", precision: nil
    t.string "name"
    t.string "phone_number"
    t.datetime "updated_at", null: false
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.string "job_class"
    t.bigint "job_object_id"
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["active_job_id"], name: "index_delayed_jobs_on_active_job_id"
    t.index ["job_class", "job_object_id"], name: "index_delayed_jobs_on_job_class_and_job_object_id"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "dependents", force: :cascade do |t|
    t.integer "below_qualifying_relative_income_requirement", default: 0
    t.date "birth_date", null: false
    t.integer "cant_be_claimed_by_other", default: 0, null: false
    t.integer "claim_anyway", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "creation_token"
    t.integer "disabled", default: 0, null: false
    t.integer "filed_joint_return", default: 0, null: false
    t.integer "filer_provided_over_half_housing_support", default: 0, null: false
    t.integer "filer_provided_over_half_support", default: 0
    t.string "first_name"
    t.integer "full_time_student", default: 0, null: false
    t.integer "has_ip_pin", default: 0, null: false
    t.string "hashed_ssn"
    t.bigint "intake_id", null: false
    t.text "ip_pin"
    t.string "last_name"
    t.integer "lived_with_more_than_six_months", default: 0, null: false
    t.integer "meets_misc_qualifying_relative_requirements", default: 0, null: false
    t.string "middle_initial"
    t.integer "months_in_home"
    t.integer "no_ssn_atin", default: 0, null: false
    t.integer "north_american_resident", default: 0, null: false
    t.integer "on_visa", default: 0, null: false
    t.integer "permanent_residence_with_client", default: 0, null: false
    t.integer "permanently_totally_disabled", default: 0, null: false
    t.integer "provided_over_half_own_support", default: 0, null: false
    t.string "relationship"
    t.integer "residence_exception_adoption", default: 0, null: false
    t.integer "residence_exception_born", default: 0, null: false
    t.integer "residence_exception_passed_away", default: 0, null: false
    t.integer "residence_lived_with_all_year", default: 0
    t.datetime "soft_deleted_at", precision: nil
    t.text "ssn"
    t.string "suffix"
    t.integer "tin_type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "us_citizen", default: 0, null: false
    t.integer "was_married", default: 0, null: false
    t.integer "was_student", default: 0, null: false
    t.index ["creation_token"], name: "index_dependents_on_creation_token"
    t.index ["intake_id"], name: "index_dependents_on_intake_id"
  end

  create_table "diy_intakes", force: :cascade do |t|
    t.datetime "clicked_chat_with_us_at"
    t.datetime "created_at", null: false
    t.string "email_address"
    t.integer "filing_frequency", default: 0, null: false
    t.string "locale"
    t.string "preferred_first_name"
    t.integer "received_1099", default: 0, null: false
    t.string "referrer"
    t.string "source"
    t.string "token"
    t.datetime "updated_at", null: false
    t.string "visitor_id"
    t.string "zip_code"
  end

  create_table "documents", force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.float "blur_score"
    t.bigint "client_id"
    t.bigint "contact_record_id"
    t.string "contact_record_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "display_name"
    t.string "document_type", null: false
    t.bigint "documents_request_id"
    t.bigint "intake_id"
    t.integer "person", default: 0, null: false
    t.bigint "tax_return_id"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "uploaded_by_id"
    t.string "uploaded_by_type"
    t.index ["client_id"], name: "index_documents_on_client_id"
    t.index ["contact_record_type", "contact_record_id"], name: "index_documents_on_contact_record_type_and_contact_record_id"
    t.index ["documents_request_id"], name: "index_documents_on_documents_request_id"
    t.index ["intake_id"], name: "index_documents_on_intake_id"
    t.index ["tax_return_id"], name: "index_documents_on_tax_return_id"
    t.index ["uploaded_by_type", "uploaded_by_id"], name: "index_documents_on_uploaded_by_type_and_uploaded_by_id"
  end

  create_table "documents_requests", force: :cascade do |t|
    t.bigint "client_id"
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_documents_requests_on_client_id"
  end

  create_table "drivers_licenses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expiration_date", null: false
    t.date "issue_date", null: false
    t.string "license_number", null: false
    t.string "state", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ds_click_histories", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "w2_logout_add_later", precision: nil
    t.index ["client_id"], name: "index_ds_click_histories_on_client_id", unique: true
  end

  create_table "efile_errors", force: :cascade do |t|
    t.boolean "auto_cancel", default: false
    t.boolean "auto_wait", default: false
    t.string "category"
    t.string "code"
    t.datetime "created_at", null: false
    t.boolean "expose", default: true
    t.text "message"
    t.string "severity"
    t.string "source"
    t.datetime "updated_at", null: false
  end

  create_table "efile_security_informations", force: :cascade do |t|
    t.string "browser_language"
    t.bigint "client_id"
    t.string "client_system_time"
    t.datetime "created_at", null: false
    t.string "device_id"
    t.bigint "efile_submission_id"
    t.inet "ip_address"
    t.string "platform"
    t.decimal "recaptcha_score"
    t.string "timezone"
    t.string "timezone_offset"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["client_id"], name: "index_efile_security_informations_on_client_id"
    t.index ["efile_submission_id"], name: "index_client_efile_security_informations_efile_submissions_id"
  end

  create_table "efile_submission_dependents", force: :cascade do |t|
    t.integer "age_during_tax_year"
    t.datetime "created_at", null: false
    t.bigint "dependent_id"
    t.bigint "efile_submission_id"
    t.boolean "qualifying_child"
    t.boolean "qualifying_ctc"
    t.boolean "qualifying_eitc"
    t.boolean "qualifying_relative"
    t.datetime "updated_at", null: false
    t.index ["dependent_id"], name: "index_efile_submission_dependents_on_dependent_id"
    t.index ["efile_submission_id"], name: "index_efile_submission_dependents_on_efile_submission_id"
  end

  create_table "efile_submission_transition_errors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "dependent_id"
    t.bigint "efile_error_id"
    t.bigint "efile_submission_id"
    t.bigint "efile_submission_transition_id"
    t.datetime "updated_at", null: false
    t.index ["dependent_id"], name: "index_efile_submission_transition_errors_on_dependent_id"
    t.index ["efile_error_id"], name: "index_efile_submission_transition_errors_on_efile_error_id"
    t.index ["efile_submission_id"], name: "index_efile_submission_transition_errors_on_efile_submission_id"
    t.index ["efile_submission_transition_id"], name: "index_este_on_esti"
  end

  create_table "efile_submission_transitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "efile_submission_id", null: false
    t.jsonb "metadata", default: {}
    t.boolean "most_recent", null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_efile_submission_transitions_on_created_at"
    t.index ["efile_submission_id", "most_recent"], name: "index_efile_submission_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["efile_submission_id", "sort_key"], name: "index_efile_submission_transitions_parent_sort", unique: true
  end

  create_table "efile_submissions", force: :cascade do |t|
    t.boolean "claimed_eitc"
    t.datetime "created_at", null: false
    t.bigint "data_source_id"
    t.string "data_source_type"
    t.string "irs_submission_id"
    t.datetime "last_checked_for_ack_at", precision: nil
    t.bigint "tax_return_id"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_efile_submissions_on_created_at"
    t.index ["data_source_type", "data_source_id"], name: "index_efile_submissions_on_data_source"
    t.index ["irs_submission_id"], name: "index_efile_submissions_on_irs_submission_id"
    t.index ["tax_return_id", "id"], name: "index_efile_submissions_on_tax_return_id_and_id", order: { id: :desc }
    t.index ["tax_return_id"], name: "index_efile_submissions_on_tax_return_id"
  end

  create_table "email_access_tokens", force: :cascade do |t|
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.citext "email_address", null: false
    t.string "token", null: false
    t.string "token_type", default: "link"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_email_access_tokens_on_client_id"
    t.index ["email_address"], name: "index_email_access_tokens_on_email_address"
    t.index ["token"], name: "index_email_access_tokens_on_token"
  end

  create_table "email_login_requests", force: :cascade do |t|
    t.bigint "email_access_token_id", null: false
    t.string "mailgun_id"
    t.string "mailgun_status"
    t.string "visitor_id", null: false
    t.index ["email_access_token_id"], name: "index_email_login_requests_on_email_access_token_id"
    t.index ["mailgun_id"], name: "index_email_login_requests_on_mailgun_id"
    t.index ["visitor_id"], name: "index_email_login_requests_on_visitor_id"
  end

  create_table "experiment_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "experiment_id"
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.string "treatment"
    t.datetime "updated_at", null: false
    t.index ["experiment_id"], name: "index_experiment_participants_on_experiment_id"
    t.index ["record_type", "record_id"], name: "index_experiment_participants_on_record"
  end

  create_table "experiment_vita_partners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "experiment_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "vita_partner_id", null: false
    t.index ["experiment_id"], name: "index_experiment_vita_partners_on_experiment_id"
    t.index ["vita_partner_id"], name: "index_experiment_vita_partners_on_vita_partner_id"
  end

  create_table "experiments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false
    t.string "key"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_experiments_on_key", unique: true
  end

  create_table "faq_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name_en"
    t.string "name_es"
    t.integer "position"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "faq_items", force: :cascade do |t|
    t.text "answer_en"
    t.text "answer_es"
    t.datetime "created_at", null: false
    t.bigint "faq_category_id", null: false
    t.integer "position"
    t.text "question_en"
    t.text "question_es"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["faq_category_id"], name: "index_faq_items_on_faq_category_id"
  end

  create_table "faq_question_group_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "faq_item_id", null: false
    t.string "group_name"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["faq_item_id"], name: "index_faq_question_group_items_on_faq_item_id"
  end

  create_table "faq_surveys", force: :cascade do |t|
    t.integer "answer", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "question_key", null: false
    t.datetime "updated_at", null: false
    t.string "visitor_id", null: false
    t.index ["visitor_id", "question_key"], name: "index_faq_surveys_on_visitor_id_and_question_key"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "feature_key", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "fraud_indicators", force: :cascade do |t|
    t.datetime "activated_at", precision: nil
    t.datetime "created_at", null: false
    t.text "description"
    t.string "indicator_attributes", default: [], array: true
    t.string "indicator_type"
    t.string "list_model_name"
    t.float "multiplier"
    t.string "name"
    t.integer "points"
    t.string "query_model_name"
    t.string "reference"
    t.float "threshold"
    t.datetime "updated_at", null: false
  end

  create_table "fraud_indicators_domains", force: :cascade do |t|
    t.datetime "activated_at", precision: nil
    t.datetime "created_at", null: false
    t.string "name"
    t.boolean "risky"
    t.boolean "safe"
    t.datetime "updated_at", null: false
    t.index ["risky"], name: "index_fraud_indicators_domains_on_risky"
    t.index ["safe"], name: "index_fraud_indicators_domains_on_safe"
  end

  create_table "fraud_indicators_routing_numbers", force: :cascade do |t|
    t.datetime "activated_at", precision: nil
    t.string "bank_name"
    t.datetime "created_at", null: false
    t.integer "extra_points"
    t.string "routing_number"
    t.datetime "updated_at", null: false
  end

  create_table "fraud_indicators_timezones", force: :cascade do |t|
    t.datetime "activated_at", precision: nil
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "fraud_scores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "efile_submission_id"
    t.integer "score"
    t.jsonb "snapshot"
    t.datetime "updated_at", null: false
    t.index ["efile_submission_id"], name: "index_fraud_scores_on_efile_submission_id"
  end

  create_table "greeter_coalition_join_records", force: :cascade do |t|
    t.bigint "coalition_id", null: false
    t.datetime "created_at", null: false
    t.bigint "greeter_role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["coalition_id"], name: "index_greeter_coalition_join_records_on_coalition_id"
    t.index ["greeter_role_id"], name: "index_greeter_coalition_join_records_on_greeter_role_id"
  end

  create_table "greeter_organization_join_records", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "greeter_role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "vita_partner_id", null: false
    t.index ["greeter_role_id"], name: "index_greeter_organization_join_records_on_greeter_role_id"
    t.index ["vita_partner_id"], name: "index_greeter_organization_join_records_on_vita_partner_id"
  end

  create_table "greeter_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incoming_emails", force: :cascade do |t|
    t.integer "attachment_count"
    t.string "body_html"
    t.string "body_plain"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.citext "from", null: false
    t.string "message_id"
    t.string "received"
    t.datetime "received_at", precision: nil, null: false
    t.string "recipient", null: false
    t.string "sender", null: false
    t.string "stripped_html"
    t.string "stripped_signature"
    t.string "stripped_text"
    t.string "subject"
    t.citext "to"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["client_id"], name: "index_incoming_emails_on_client_id"
    t.index ["created_at"], name: "index_incoming_emails_on_created_at"
  end

  create_table "incoming_portal_messages", force: :cascade do |t|
    t.text "body"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_incoming_portal_messages_on_client_id"
    t.index ["created_at"], name: "index_incoming_portal_messages_on_created_at"
  end

  create_table "incoming_text_messages", force: :cascade do |t|
    t.string "body"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "from_phone_number", null: false
    t.datetime "received_at", precision: nil, null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_incoming_text_messages_on_client_id"
    t.index ["created_at"], name: "index_incoming_text_messages_on_created_at"
  end

  create_table "intake_archives", force: :cascade do |t|
    t.integer "had_student_in_family"
    t.integer "needs_help_2017"
    t.integer "spouse_was_on_visa"
    t.integer "was_on_visa"
  end

  create_table "intakes", force: :cascade do |t|
    t.string "additional_info"
    t.integer "adopted_child", default: 0, null: false
    t.integer "advance_ctc_amount_received"
    t.integer "advance_ctc_entry_method", default: 0, null: false
    t.integer "already_applied_for_stimulus", default: 0, null: false
    t.integer "already_filed", default: 0, null: false
    t.integer "balance_pay_from_bank", default: 0, null: false
    t.text "bank_account_number"
    t.integer "bank_account_type", default: 0, null: false
    t.string "bank_name"
    t.string "bank_routing_number"
    t.integer "bought_employer_health_insurance", default: 0, null: false
    t.integer "bought_energy_efficient_items"
    t.integer "bought_marketplace_health_insurance", default: 0, null: false
    t.integer "cannot_claim_me_as_a_dependent", default: 0, null: false
    t.string "canonical_email_address"
    t.string "city"
    t.integer "claim_eitc", default: 0, null: false
    t.integer "claim_owed_stimulus_money", default: 0, null: false
    t.integer "claimed_by_another", default: 0, null: false
    t.bigint "client_id"
    t.datetime "completed_at", precision: nil
    t.datetime "completed_yes_no_questions_at", precision: nil
    t.integer "consented_to_legal", default: 0, null: false
    t.boolean "continued_at_capacity", default: false
    t.integer "contributed_to_401k", default: 0, null: false
    t.integer "contributed_to_ira", default: 0, null: false
    t.integer "contributed_to_other_retirement_account", default: 0, null: false
    t.integer "contributed_to_roth_ira", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "current_step"
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
    t.boolean "demographic_questions_hub_edit", default: false
    t.integer "demographic_questions_opt_in", default: 0, null: false
    t.boolean "demographic_spouse_american_indian_alaska_native"
    t.boolean "demographic_spouse_asian"
    t.boolean "demographic_spouse_black_african_american"
    t.integer "demographic_spouse_ethnicity", default: 0, null: false
    t.boolean "demographic_spouse_native_hawaiian_pacific_islander"
    t.boolean "demographic_spouse_prefer_not_to_answer_race"
    t.boolean "demographic_spouse_white"
    t.integer "demographic_veteran", default: 0, null: false
    t.boolean "disallowed_ctc"
    t.integer "divorced", default: 0, null: false
    t.string "divorced_year"
    t.integer "eip1_amount_received"
    t.integer "eip1_and_2_amount_received_confidence"
    t.integer "eip1_entry_method", default: 0, null: false
    t.integer "eip2_amount_received"
    t.integer "eip2_entry_method", default: 0, null: false
    t.integer "eip3_amount_received"
    t.integer "eip3_entry_method", default: 0, null: false
    t.boolean "eip_only"
    t.citext "email_address"
    t.datetime "email_address_verified_at", precision: nil
    t.string "email_domain"
    t.integer "email_notification_opt_in", default: 0, null: false
    t.integer "ever_married", default: 0, null: false
    t.integer "ever_owned_home", default: 0, null: false
    t.integer "exceeded_investment_income_limit", default: 0
    t.string "feedback"
    t.integer "feeling_about_taxes", default: 0, null: false
    t.integer "filed_2020", default: 0, null: false
    t.integer "filed_prior_tax_year", default: 0, null: false
    t.integer "filing_for_stimulus", default: 0, null: false
    t.integer "filing_joint", default: 0, null: false
    t.string "final_info"
    t.integer "former_foster_youth", default: 0, null: false
    t.integer "full_time_student_less_than_five_months", default: 0, null: false
    t.integer "got_married_during_tax_year", default: 0, null: false
    t.integer "had_asset_sale_income", default: 0, null: false
    t.integer "had_capital_loss_carryover", default: 0, null: false
    t.integer "had_cash_check_digital_assets", default: 0, null: false
    t.integer "had_debt_forgiven", default: 0, null: false
    t.integer "had_dependents", default: 0, null: false
    t.integer "had_disability", default: 0, null: false
    t.integer "had_disability_income", default: 0, null: false
    t.integer "had_disaster_loss", default: 0, null: false
    t.string "had_disaster_loss_where"
    t.integer "had_disqualifying_non_w2_income"
    t.integer "had_farm_income", default: 0, null: false
    t.integer "had_gambling_income", default: 0, null: false
    t.integer "had_hsa", default: 0, null: false
    t.integer "had_interest_income", default: 0, null: false
    t.integer "had_local_tax_refund", default: 0, null: false
    t.integer "had_medicaid_medicare", default: 0, null: false
    t.integer "had_other_income", default: 0, null: false
    t.integer "had_rental_income", default: 0, null: false
    t.integer "had_retirement_income", default: 0, null: false
    t.integer "had_scholarships", default: 0, null: false
    t.integer "had_self_employment_income", default: 0, null: false
    t.integer "had_social_security_income", default: 0, null: false
    t.integer "had_social_security_or_retirement", default: 0, null: false
    t.integer "had_student_in_family", default: 0, null: false
    t.integer "had_tax_credit_disallowed", default: 0, null: false
    t.integer "had_tips", default: 0, null: false
    t.integer "had_unemployment_income", default: 0, null: false
    t.integer "had_w2s", default: 0, null: false
    t.integer "had_wages", default: 0, null: false
    t.boolean "has_crypto_income", default: false
    t.integer "has_primary_ip_pin", default: 0, null: false
    t.integer "has_spouse_ip_pin", default: 0, null: false
    t.integer "has_ssn_of_alimony_recipient", default: 0, null: false
    t.string "hashed_primary_ssn"
    t.string "hashed_spouse_ssn"
    t.integer "home_location"
    t.integer "homeless_youth", default: 0, null: false
    t.integer "income_over_limit", default: 0, null: false
    t.string "interview_timing_preference"
    t.integer "irs_language_preference"
    t.integer "issued_identity_pin", default: 0, null: false
    t.integer "job_count"
    t.integer "lived_with_spouse", default: 0, null: false
    t.string "locale"
    t.integer "made_estimated_tax_payments", default: 0, null: false
    t.decimal "made_estimated_tax_payments_amount", precision: 12, scale: 2
    t.integer "married", default: 0, null: false
    t.bigint "matching_previous_year_intake_id"
    t.integer "multiple_states", default: 0, null: false
    t.boolean "navigator_has_verified_client_identity"
    t.string "navigator_name"
    t.integer "need_itin_help", default: 0, null: false
    t.integer "needs_help_2016", default: 0, null: false
    t.integer "needs_help_2018", default: 0, null: false
    t.integer "needs_help_2019", default: 0, null: false
    t.integer "needs_help_2020", default: 0, null: false
    t.integer "needs_help_2021", default: 0, null: false
    t.integer "needs_help_current_year", default: 0, null: false
    t.integer "needs_help_previous_year_1", default: 0, null: false
    t.integer "needs_help_previous_year_2", default: 0, null: false
    t.integer "needs_help_previous_year_3", default: 0, null: false
    t.datetime "needs_to_flush_searchable_data_set_at", precision: nil
    t.integer "no_eligibility_checks_apply", default: 0, null: false
    t.integer "no_ssn", default: 0, null: false
    t.integer "not_full_time_student", default: 0, null: false
    t.string "other_income_types"
    t.integer "paid_alimony", default: 0, null: false
    t.integer "paid_charitable_contributions", default: 0, null: false
    t.integer "paid_dependent_care", default: 0, null: false
    t.integer "paid_local_tax", default: 0, null: false
    t.integer "paid_medical_expenses", default: 0, null: false
    t.integer "paid_mortgage_interest", default: 0, null: false
    t.integer "paid_post_secondary_educational_expenses", default: 0, null: false
    t.integer "paid_retirement_contributions", default: 0, null: false
    t.integer "paid_school_supplies", default: 0, null: false
    t.integer "paid_self_employment_expenses", default: 0, null: false
    t.integer "paid_student_loan_interest", default: 0, null: false
    t.string "phone_carrier"
    t.string "phone_number"
    t.integer "phone_number_can_receive_texts", default: 0, null: false
    t.string "phone_number_type"
    t.string "preferred_interview_language"
    t.string "preferred_name"
    t.string "preferred_written_language"
    t.integer "presidential_campaign_fund_donation", default: 0, null: false
    t.integer "primary_active_armed_forces", default: 0, null: false
    t.date "primary_birth_date"
    t.integer "primary_consented_to_service", default: 0, null: false
    t.inet "primary_consented_to_service_ip"
    t.bigint "primary_drivers_license_id"
    t.string "primary_first_name"
    t.text "primary_ip_pin"
    t.string "primary_job_title"
    t.text "primary_last_four_ssn"
    t.string "primary_last_name"
    t.string "primary_middle_initial"
    t.integer "primary_prior_year_agi_amount"
    t.string "primary_prior_year_signature_pin"
    t.text "primary_signature_pin"
    t.datetime "primary_signature_pin_at", precision: nil
    t.text "primary_ssn"
    t.string "primary_suffix"
    t.integer "primary_tin_type"
    t.integer "primary_us_citizen", default: 0, null: false
    t.integer "product_year", null: false
    t.integer "receive_written_communication", default: 0, null: false
    t.integer "received_advance_ctc_payment"
    t.integer "received_alimony", default: 0, null: false
    t.integer "received_homebuyer_credit", default: 0, null: false
    t.integer "received_irs_letter", default: 0, null: false
    t.integer "received_stimulus_payment", default: 0, null: false
    t.string "referrer"
    t.integer "refund_payment_method", default: 0, null: false
    t.integer "register_to_vote", default: 0, null: false
    t.integer "reported_asset_sale_loss", default: 0, null: false
    t.integer "reported_self_employment_loss", default: 0, null: false
    t.string "requested_docs_token"
    t.datetime "requested_docs_token_created_at", precision: nil
    t.datetime "routed_at", precision: nil
    t.string "routing_criteria"
    t.string "routing_value"
    t.integer "satisfaction_face", default: 0, null: false
    t.integer "savings_purchase_bond", default: 0, null: false
    t.integer "savings_split_refund", default: 0, null: false
    t.tsvector "searchable_data"
    t.integer "separated", default: 0, null: false
    t.string "separated_year"
    t.integer "signature_method", default: 0, null: false
    t.integer "sms_notification_opt_in", default: 0, null: false
    t.string "sms_phone_number"
    t.datetime "sms_phone_number_verified_at", precision: nil
    t.integer "sold_a_home", default: 0, null: false
    t.integer "sold_assets", default: 0, null: false
    t.string "source"
    t.integer "spouse_active_armed_forces", default: 0
    t.string "spouse_auth_token"
    t.date "spouse_birth_date"
    t.integer "spouse_consented_to_service", default: 0, null: false
    t.datetime "spouse_consented_to_service_at", precision: nil
    t.inet "spouse_consented_to_service_ip"
    t.bigint "spouse_drivers_license_id"
    t.citext "spouse_email_address"
    t.integer "spouse_filed_prior_tax_year", default: 0, null: false
    t.string "spouse_first_name"
    t.integer "spouse_had_disability", default: 0, null: false
    t.text "spouse_ip_pin"
    t.integer "spouse_issued_identity_pin", default: 0, null: false
    t.string "spouse_job_title"
    t.text "spouse_last_four_ssn"
    t.string "spouse_last_name"
    t.string "spouse_middle_initial"
    t.string "spouse_phone_number"
    t.integer "spouse_prior_year_agi_amount"
    t.string "spouse_prior_year_signature_pin"
    t.text "spouse_signature_pin"
    t.datetime "spouse_signature_pin_at", precision: nil
    t.text "spouse_ssn"
    t.string "spouse_suffix"
    t.integer "spouse_tin_type"
    t.integer "spouse_us_citizen", default: 0, null: false
    t.integer "spouse_was_blind", default: 0, null: false
    t.integer "spouse_was_full_time_student", default: 0, null: false
    t.string "state"
    t.string "state_of_residence"
    t.string "street_address"
    t.string "street_address2"
    t.integer "tax_credit_disallowed_year"
    t.string "timezone"
    t.integer "triage_filing_frequency", default: 0, null: false
    t.integer "triage_filing_status", default: 0, null: false
    t.integer "triage_income_level", default: 0, null: false
    t.integer "triage_vita_income_ineligible", default: 0, null: false
    t.string "type"
    t.datetime "updated_at", null: false
    t.string "urbanization"
    t.boolean "use_primary_name_for_name_control", default: false
    t.boolean "used_itin_certifying_acceptance_agent", default: false, null: false
    t.integer "usps_address_late_verification_attempts", default: 0
    t.datetime "usps_address_verified_at"
    t.boolean "viewed_at_capacity", default: false
    t.string "visitor_id"
    t.bigint "vita_partner_id"
    t.integer "wants_to_itemize", default: 0, null: false
    t.integer "was_blind", default: 0, null: false
    t.integer "was_full_time_student", default: 0, null: false
    t.integer "widowed", default: 0, null: false
    t.string "widowed_year"
    t.boolean "with_drivers_license_photo_id", default: false
    t.boolean "with_general_navigator", default: false
    t.boolean "with_incarcerated_navigator", default: false
    t.boolean "with_itin_taxpayer_id", default: false
    t.boolean "with_limited_english_navigator", default: false
    t.boolean "with_other_state_photo_id", default: false
    t.boolean "with_passport_photo_id", default: false
    t.boolean "with_social_security_taxpayer_id", default: false
    t.boolean "with_unhoused_navigator", default: false
    t.boolean "with_vita_approved_photo_id", default: false
    t.boolean "with_vita_approved_taxpayer_id", default: false
    t.string "zip_code"
    t.index ["canonical_email_address"], name: "index_intakes_on_canonical_email_address"
    t.index ["client_id"], name: "index_intakes_on_client_id"
    t.index ["completed_at"], name: "index_intakes_on_completed_at", where: "(completed_at IS NOT NULL)"
    t.index ["email_address"], name: "index_intakes_on_email_address"
    t.index ["email_domain"], name: "index_intakes_on_email_domain"
    t.index ["hashed_primary_ssn"], name: "index_intakes_on_hashed_primary_ssn"
    t.index ["matching_previous_year_intake_id"], name: "index_intakes_on_matching_previous_year_intake_id"
    t.index ["needs_to_flush_searchable_data_set_at"], name: "index_intakes_on_needs_to_flush_searchable_data_set_at", where: "(needs_to_flush_searchable_data_set_at IS NOT NULL)"
    t.index ["phone_number"], name: "index_intakes_on_phone_number"
    t.index ["primary_consented_to_service"], name: "index_intakes_on_primary_consented_to_service"
    t.index ["primary_drivers_license_id"], name: "index_intakes_on_primary_drivers_license_id"
    t.index ["searchable_data"], name: "index_intakes_on_searchable_data", using: :gin
    t.index ["sms_phone_number"], name: "index_intakes_on_sms_phone_number"
    t.index ["spouse_drivers_license_id"], name: "index_intakes_on_spouse_drivers_license_id"
    t.index ["spouse_email_address"], name: "index_intakes_on_spouse_email_address"
    t.index ["type"], name: "index_intakes_on_type"
    t.index ["vita_partner_id"], name: "index_intakes_on_vita_partner_id"
  end

  create_table "internal_emails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "mail_args", default: {}
    t.string "mail_class"
    t.string "mail_method"
    t.datetime "updated_at", null: false
    t.index ["mail_class", "mail_method", "mail_args"], name: "idx_internal_emails_mail_info"
  end

  create_table "notes", force: :cascade do |t|
    t.text "body"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["client_id"], name: "index_notes_on_client_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "organization_lead_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vita_partner_id", null: false
    t.index ["vita_partner_id"], name: "index_organization_lead_roles_on_vita_partner_id"
  end

  create_table "outbound_calls", force: :cascade do |t|
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.string "from_phone_number", null: false
    t.text "note"
    t.integer "queue_time_ms"
    t.string "to_phone_number", null: false
    t.integer "twilio_call_duration"
    t.string "twilio_sid"
    t.string "twilio_status"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["client_id"], name: "index_outbound_calls_on_client_id"
    t.index ["created_at"], name: "index_outbound_calls_on_created_at"
    t.index ["user_id"], name: "index_outbound_calls_on_user_id"
  end

  create_table "outgoing_emails", force: :cascade do |t|
    t.string "body", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "mailgun_status", default: "sending"
    t.string "message_id"
    t.datetime "sent_at", precision: nil
    t.string "subject", null: false
    t.citext "to", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["client_id"], name: "index_outgoing_emails_on_client_id"
    t.index ["created_at"], name: "index_outgoing_emails_on_created_at"
    t.index ["message_id"], name: "index_outgoing_emails_on_message_id"
    t.index ["user_id"], name: "index_outgoing_emails_on_user_id"
  end

  create_table "outgoing_message_statuses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "delivery_status"
    t.string "error_code"
    t.text "message_id"
    t.integer "message_type", null: false
    t.bigint "parent_id", null: false
    t.string "parent_type", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_type", "parent_id"], name: "index_outgoing_message_statuses_on_parent"
  end

  create_table "outgoing_text_messages", force: :cascade do |t|
    t.string "body", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "error_code"
    t.datetime "sent_at", precision: nil
    t.string "to_phone_number", null: false
    t.string "twilio_sid"
    t.string "twilio_status"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["client_id"], name: "index_outgoing_text_messages_on_client_id"
    t.index ["created_at"], name: "index_outgoing_text_messages_on_created_at"
    t.index ["user_id"], name: "index_outgoing_text_messages_on_user_id"
  end

  create_table "provider_scrapes", force: :cascade do |t|
    t.integer "archived_count", default: 0, null: false
    t.integer "changed_count", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "recaptcha_scores", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.decimal "score", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_recaptcha_scores_on_client_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.datetime "generated_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["generated_at"], name: "index_reports_on_generated_at"
  end

  create_table "signup_selections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "filename", null: false
    t.integer "id_array", null: false, array: true
    t.integer "signup_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_signup_selections_on_user_id"
  end

  create_table "signups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ctc_2022_open_message_sent_at", precision: nil
    t.citext "email_address"
    t.string "name"
    t.string "phone_number"
    t.datetime "puerto_rico_open_message_sent_at"
    t.datetime "updated_at", null: false
    t.string "zip_code"
  end

  create_table "site_coordinator_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "site_coordinator_roles_vita_partners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "site_coordinator_role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "vita_partner_id", null: false
    t.index ["site_coordinator_role_id"], name: "index_scr_vita_partners_on_scr_id"
    t.index ["vita_partner_id"], name: "index_site_coordinator_roles_vita_partners_on_vita_partner_id"
  end

  create_table "source_parameters", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vita_partner_id", null: false
    t.index ["code"], name: "index_source_parameters_on_code", unique: true
    t.index ["vita_partner_id"], name: "index_source_parameters_on_vita_partner_id"
  end

  create_table "state_file1099s", force: :cascade do |t|
    t.integer "address_confirmation", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "federal_income_tax_withheld"
    t.bigint "intake_id", null: false
    t.string "intake_type", null: false
    t.string "payer_name"
    t.integer "payer_name_is_default", default: 0, null: false
    t.integer "recipient", default: 0, null: false
    t.string "recipient_city"
    t.string "recipient_state"
    t.string "recipient_street_address"
    t.string "recipient_zip"
    t.integer "state_income_tax_withheld"
    t.integer "unemployment_compensation"
    t.datetime "updated_at", null: false
    t.index ["intake_type", "intake_id"], name: "index_state_file1099s_on_intake"
  end

  create_table "state_file_az_intakes", force: :cascade do |t|
    t.integer "armed_forces_member", default: 0, null: false
    t.integer "armed_forces_wages"
    t.string "bank_account_number"
    t.integer "bank_account_type"
    t.string "bank_routing_number"
    t.integer "charitable_cash", default: 0
    t.integer "charitable_contributions", default: 0, null: false
    t.integer "charitable_noncash", default: 0
    t.integer "claimed_as_dep", default: 0
    t.integer "contact_preference", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "current_step"
    t.citext "email_address"
    t.datetime "email_address_verified_at"
    t.integer "has_prior_last_names", default: 0, null: false
    t.string "phone_number"
    t.datetime "phone_number_verified_at"
    t.string "primary_first_name"
    t.string "primary_last_name"
    t.string "primary_middle_initial"
    t.string "prior_last_names"
    t.text "raw_direct_file_data"
    t.string "referrer"
    t.string "source"
    t.string "spouse_first_name"
    t.string "spouse_last_name"
    t.string "spouse_middle_initial"
    t.integer "tribal_member", default: 0, null: false
    t.integer "tribal_wages"
    t.datetime "updated_at", null: false
    t.string "visitor_id"
  end

  create_table "state_file_dependents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "dob"
    t.boolean "eic_disability"
    t.boolean "eic_qualifying"
    t.boolean "eic_student"
    t.string "first_name"
    t.bigint "intake_id", null: false
    t.string "intake_type", null: false
    t.string "last_name"
    t.string "middle_initial"
    t.integer "months_in_home"
    t.integer "needed_assistance", default: 0, null: false
    t.integer "passed_away", default: 0, null: false
    t.string "relationship"
    t.string "ssn"
    t.string "suffix"
    t.datetime "updated_at", null: false
    t.index ["intake_type", "intake_id"], name: "index_state_file_dependents_on_intake"
  end

  create_table "state_file_ny_intakes", force: :cascade do |t|
    t.string "account_number"
    t.integer "account_type", default: 0, null: false
    t.integer "amount_electronic_withdrawal"
    t.integer "amount_owed_pay_electronically", default: 0, null: false
    t.integer "claimed_as_dep", default: 0, null: false
    t.integer "confirmed_permanent_address", default: 0, null: false
    t.integer "contact_preference", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "current_step"
    t.date "date_electronic_withdrawal"
    t.citext "email_address"
    t.datetime "email_address_verified_at"
    t.integer "household_cash_assistance"
    t.integer "household_fed_agi"
    t.integer "household_ny_additions"
    t.integer "household_other_income"
    t.integer "household_own_assessments"
    t.integer "household_own_propety_tax"
    t.integer "household_rent_adjustments"
    t.integer "household_rent_amount"
    t.integer "household_rent_own", default: 0, null: false
    t.integer "household_ssi"
    t.string "mailing_country"
    t.string "mailing_state"
    t.integer "nursing_home", default: 0, null: false
    t.integer "ny_414h_retirement"
    t.string "ny_mailing_apartment"
    t.string "ny_mailing_city"
    t.string "ny_mailing_street"
    t.string "ny_mailing_zip"
    t.integer "ny_other_additions"
    t.integer "nyc_full_year_resident", default: 0, null: false
    t.integer "occupied_residence", default: 0, null: false
    t.string "permanent_apartment"
    t.string "permanent_city"
    t.string "permanent_street"
    t.string "permanent_zip"
    t.string "phone_number"
    t.datetime "phone_number_verified_at"
    t.date "primary_birth_date"
    t.string "primary_email"
    t.string "primary_first_name"
    t.string "primary_last_name"
    t.string "primary_middle_initial"
    t.string "primary_signature"
    t.integer "property_over_limit", default: 0, null: false
    t.integer "public_housing", default: 0, null: false
    t.text "raw_direct_file_data"
    t.string "referrer"
    t.integer "refund_choice", default: 0, null: false
    t.string "residence_county"
    t.string "routing_number"
    t.integer "sales_use_tax"
    t.integer "sales_use_tax_calculation_method", default: 0, null: false
    t.string "school_district"
    t.integer "school_district_number"
    t.string "source"
    t.date "spouse_birth_date"
    t.string "spouse_first_name"
    t.string "spouse_last_name"
    t.string "spouse_middle_initial"
    t.string "spouse_signature"
    t.integer "untaxed_out_of_state_purchases", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "visitor_id"
  end

  create_table "state_routing_fractions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "org_level_routing_enabled"
    t.float "routing_fraction", default: 0.0, null: false
    t.bigint "state_routing_target_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "vita_partner_id", null: false
    t.index ["state_routing_target_id"], name: "index_state_routing_fractions_on_state_routing_target_id"
    t.index ["vita_partner_id"], name: "index_state_routing_fractions_on_vita_partner_id"
  end

  create_table "state_routing_targets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "state_abbreviation", null: false
    t.bigint "target_id", null: false
    t.string "target_type", null: false
    t.datetime "updated_at", null: false
    t.index ["target_type", "target_id"], name: "index_state_routing_targets_on_target"
  end

  create_table "system_notes", force: :cascade do |t|
    t.text "body"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.string "type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["client_id"], name: "index_system_notes_on_client_id"
    t.index ["user_id"], name: "index_system_notes_on_user_id"
  end

  create_table "tax_return_assignments", force: :cascade do |t|
    t.bigint "assigner_id"
    t.datetime "created_at", null: false
    t.bigint "tax_return_id", null: false
    t.datetime "updated_at", null: false
    t.index ["assigner_id"], name: "index_tax_return_assignments_on_assigner_id"
    t.index ["tax_return_id"], name: "index_tax_return_assignments_on_tax_return_id"
  end

  create_table "tax_return_selection_tax_returns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tax_return_id", null: false
    t.bigint "tax_return_selection_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_return_id"], name: "index_trstr_on_tax_return_id"
    t.index ["tax_return_selection_id"], name: "index_trstr_on_tax_return_selection_id"
  end

  create_table "tax_return_selections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tax_return_transitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.boolean "most_recent", null: false
    t.integer "sort_key", null: false
    t.integer "tax_return_id", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_return_id", "most_recent"], name: "index_tax_return_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["tax_return_id", "sort_key"], name: "index_tax_return_transitions_parent_sort", unique: true
    t.index ["to_state", "created_at"], name: "index_tax_return_transitions_on_to_state_and_created_at"
  end

  create_table "tax_returns", force: :cascade do |t|
    t.bigint "assigned_user_id"
    t.integer "certification_level"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "current_state", default: "intake_before_consent"
    t.integer "filing_status"
    t.text "filing_status_note"
    t.boolean "internal_efile", default: false, null: false
    t.boolean "is_ctc", default: false
    t.boolean "is_hsa"
    t.string "primary_signature"
    t.datetime "primary_signed_at", precision: nil
    t.inet "primary_signed_ip"
    t.datetime "ready_for_prep_at", precision: nil
    t.integer "service_type", default: 0
    t.string "spouse_signature"
    t.datetime "spouse_signed_at", precision: nil
    t.inet "spouse_signed_ip"
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["assigned_user_id"], name: "index_tax_returns_on_assigned_user_id"
    t.index ["client_id"], name: "index_tax_returns_on_client_id"
    t.index ["current_state"], name: "index_tax_returns_on_current_state"
    t.index ["year", "client_id"], name: "index_tax_returns_on_year_and_client_id", unique: true
    t.index ["year"], name: "index_tax_returns_on_year"
  end

  create_table "team_member_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_member_roles_vita_partners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "team_member_role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "vita_partner_id", null: false
    t.index ["team_member_role_id"], name: "index_team_member_roles_vita_partners_on_team_member_role_id"
    t.index ["vita_partner_id"], name: "index_team_member_roles_vita_partners_on_vita_partner_id"
  end

  create_table "text_message_access_tokens", force: :cascade do |t|
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.string "sms_phone_number", null: false
    t.string "token", null: false
    t.string "token_type", default: "link"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_text_message_access_tokens_on_client_id"
    t.index ["sms_phone_number"], name: "index_text_message_access_tokens_on_sms_phone_number"
    t.index ["token"], name: "index_text_message_access_tokens_on_token"
  end

  create_table "text_message_login_requests", force: :cascade do |t|
    t.bigint "text_message_access_token_id", null: false
    t.string "twilio_sid"
    t.string "twilio_status"
    t.string "visitor_id", null: false
    t.index ["text_message_access_token_id"], name: "text_message_login_request_access_token_id"
    t.index ["twilio_sid"], name: "index_text_message_login_requests_on_twilio_sid"
    t.index ["visitor_id"], name: "index_text_message_login_requests_on_visitor_id"
  end

  create_table "triages", force: :cascade do |t|
    t.integer "assistance_in_person", default: 0, null: false
    t.integer "assistance_phone_review_english", default: 0, null: false
    t.integer "assistance_phone_review_non_english", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "doc_type", default: 0, null: false
    t.integer "filed_2018", default: 0, null: false
    t.integer "filed_2019", default: 0, null: false
    t.integer "filed_2020", default: 0, null: false
    t.integer "filed_2021", default: 0, null: false
    t.integer "filing_status", default: 0, null: false
    t.integer "id_type", default: 0, null: false
    t.integer "income_level", default: 0, null: false
    t.integer "income_type_farm", default: 0, null: false
    t.integer "income_type_rent", default: 0, null: false
    t.bigint "intake_id"
    t.string "locale"
    t.string "referrer"
    t.string "source"
    t.datetime "updated_at", null: false
    t.string "visitor_id"
    t.index ["intake_id"], name: "index_triages_on_intake_id"
  end

  create_table "user_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "notifiable_id"
    t.string "notifiable_type"
    t.boolean "read", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_user_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.citext "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "external_provider"
    t.string "external_uid"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "high_quality_password_as_of"
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.bigint "invited_by_id"
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.string "name"
    t.string "phone_number"
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.bigint "role_id", null: false
    t.string "role_type", null: false
    t.boolean "should_enforce_strong_password", default: false, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "suspended_at", precision: nil
    t.string "timezone", default: "America/New_York", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_type", "role_id"], name: "index_users_on_role_type_and_role_id", unique: true
  end

  create_table "verification_attempt_transitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.boolean "most_recent", null: false
    t.integer "sort_key", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.integer "verification_attempt_id", null: false
    t.index ["verification_attempt_id", "most_recent"], name: "index_verification_attempt_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["verification_attempt_id", "sort_key"], name: "index_verification_attempt_transitions_parent_sort", unique: true
  end

  create_table "verification_attempts", force: :cascade do |t|
    t.text "client_bypass_request"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_verification_attempts_on_client_id"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.text "object_changes"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "vita_partner_zip_codes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vita_partner_id", null: false
    t.string "zip_code", null: false
    t.index ["vita_partner_id"], name: "index_vita_partner_zip_codes_on_vita_partner_id"
    t.index ["zip_code"], name: "index_vita_partner_zip_codes_on_zip_code", unique: true
  end

  create_table "vita_partners", force: :cascade do |t|
    t.boolean "accepts_itin_applicants", default: false
    t.boolean "allows_greeters"
    t.boolean "archived", default: false
    t.integer "capacity_limit"
    t.bigint "coalition_id"
    t.datetime "created_at", null: false
    t.string "logo_path"
    t.citext "name", null: false
    t.boolean "national_overflow_location", default: false
    t.bigint "parent_organization_id"
    t.boolean "processes_ctc", default: false
    t.string "timezone", default: "America/New_York"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["coalition_id"], name: "index_vita_partners_on_coalition_id"
    t.index ["parent_organization_id", "name", "coalition_id"], name: "index_vita_partners_on_parent_name_and_coalition", unique: true
    t.index ["parent_organization_id"], name: "index_vita_partners_on_parent_organization_id"
  end

  create_table "vita_providers", force: :cascade do |t|
    t.string "appointment_info"
    t.boolean "archived", default: false, null: false
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at", precision: nil
    t.string "dates"
    t.string "details"
    t.string "hours"
    t.string "irs_id", null: false
    t.string "languages"
    t.bigint "last_scrape_id"
    t.string "name"
    t.datetime "updated_at", precision: nil
    t.index ["irs_id"], name: "index_vita_providers_on_irs_id", unique: true
    t.index ["last_scrape_id"], name: "index_vita_providers_on_last_scrape_id"
  end

  create_table "w2_box14s", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "other_amount", precision: 12, scale: 2
    t.string "other_description"
    t.datetime "updated_at", null: false
    t.bigint "w2_id", null: false
    t.index ["w2_id"], name: "index_w2_box14s_on_w2_id"
  end

  create_table "w2_state_fields_groups", force: :cascade do |t|
    t.string "box15_employer_state_id_number"
    t.string "box15_state"
    t.decimal "box16_state_wages", precision: 12, scale: 2
    t.decimal "box17_state_income_tax", precision: 12, scale: 2
    t.decimal "box18_local_wages", precision: 12, scale: 2
    t.decimal "box19_local_income_tax", precision: 12, scale: 2
    t.string "box20_locality_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "w2_id", null: false
    t.index ["w2_id"], name: "index_w2_state_fields_groups_on_w2_id"
  end

  create_table "w2s", force: :cascade do |t|
    t.decimal "box10_dependent_care_benefits", precision: 12, scale: 2
    t.decimal "box11_nonqualified_plans", precision: 12, scale: 2
    t.string "box12a_code"
    t.decimal "box12a_value", precision: 12, scale: 2
    t.string "box12b_code"
    t.decimal "box12b_value", precision: 12, scale: 2
    t.string "box12c_code"
    t.decimal "box12c_value", precision: 12, scale: 2
    t.string "box12d_code"
    t.decimal "box12d_value", precision: 12, scale: 2
    t.integer "box13_retirement_plan", default: 0
    t.integer "box13_statutory_employee", default: 0
    t.integer "box13_third_party_sick_pay", default: 0
    t.decimal "box3_social_security_wages", precision: 12, scale: 2
    t.decimal "box4_social_security_tax_withheld", precision: 12, scale: 2
    t.decimal "box5_medicare_wages_and_tip_amount", precision: 12, scale: 2
    t.decimal "box6_medicare_tax_withheld", precision: 12, scale: 2
    t.decimal "box7_social_security_tips_amount", precision: 12, scale: 2
    t.decimal "box8_allocated_tips", precision: 12, scale: 2
    t.string "box_d_control_number"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "creation_token"
    t.integer "employee", default: 0, null: false
    t.string "employee_city"
    t.string "employee_state"
    t.string "employee_street_address"
    t.string "employee_zip_code"
    t.string "employer_city"
    t.string "employer_ein"
    t.string "employer_name"
    t.string "employer_state"
    t.string "employer_street_address"
    t.string "employer_zip_code"
    t.decimal "federal_income_tax_withheld", precision: 12, scale: 2
    t.bigint "intake_id"
    t.datetime "updated_at", null: false
    t.decimal "wages_amount", precision: 12, scale: 2
    t.index ["creation_token"], name: "index_w2s_on_creation_token"
    t.index ["intake_id"], name: "index_w2s_on_intake_id"
  end

  add_foreign_key "access_logs", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_toggles", "users"
  add_foreign_key "analytics_events", "clients"
  add_foreign_key "archived_bank_accounts_2021", "archived_intakes_2021"
  add_foreign_key "archived_dependents_2021", "archived_intakes_2021"
  add_foreign_key "archived_intakes_2021", "clients"
  add_foreign_key "archived_intakes_2021", "vita_partners"
  add_foreign_key "bank_accounts", "intakes"
  add_foreign_key "bulk_action_notifications", "tax_return_selections"
  add_foreign_key "bulk_client_message_outgoing_emails", "bulk_client_messages"
  add_foreign_key "bulk_client_message_outgoing_emails", "outgoing_emails"
  add_foreign_key "bulk_client_message_outgoing_text_messages", "bulk_client_messages"
  add_foreign_key "bulk_client_message_outgoing_text_messages", "outgoing_text_messages"
  add_foreign_key "bulk_client_messages", "tax_return_selections"
  add_foreign_key "bulk_client_notes", "tax_return_selections"
  add_foreign_key "bulk_client_organization_updates", "tax_return_selections"
  add_foreign_key "bulk_client_organization_updates", "vita_partners"
  add_foreign_key "bulk_message_csvs", "tax_return_selections"
  add_foreign_key "bulk_message_csvs", "users"
  add_foreign_key "bulk_signup_message_outgoing_message_statuses", "bulk_signup_messages"
  add_foreign_key "bulk_signup_message_outgoing_message_statuses", "outgoing_message_statuses"
  add_foreign_key "bulk_signup_messages", "signup_selections"
  add_foreign_key "bulk_signup_messages", "users"
  add_foreign_key "bulk_tax_return_updates", "tax_return_selections"
  add_foreign_key "bulk_tax_return_updates", "users", column: "assigned_user_id"
  add_foreign_key "clients", "vita_partners"
  add_foreign_key "coalition_lead_roles", "coalitions"
  add_foreign_key "dependents", "intakes"
  add_foreign_key "documents", "clients"
  add_foreign_key "documents", "documents_requests"
  add_foreign_key "documents", "tax_returns"
  add_foreign_key "documents_requests", "clients"
  add_foreign_key "ds_click_histories", "clients"
  add_foreign_key "efile_security_informations", "clients"
  add_foreign_key "efile_security_informations", "efile_submissions"
  add_foreign_key "efile_submission_transitions", "efile_submissions"
  add_foreign_key "experiment_vita_partners", "experiments"
  add_foreign_key "experiment_vita_partners", "vita_partners"
  add_foreign_key "faq_items", "faq_categories"
  add_foreign_key "faq_question_group_items", "faq_items"
  add_foreign_key "greeter_coalition_join_records", "coalitions"
  add_foreign_key "greeter_coalition_join_records", "greeter_roles"
  add_foreign_key "greeter_organization_join_records", "greeter_roles"
  add_foreign_key "greeter_organization_join_records", "vita_partners"
  add_foreign_key "incoming_text_messages", "clients"
  add_foreign_key "intake_archives", "intakes", column: "id"
  add_foreign_key "intakes", "clients"
  add_foreign_key "intakes", "intakes", column: "matching_previous_year_intake_id"
  add_foreign_key "intakes", "vita_partners"
  add_foreign_key "notes", "clients"
  add_foreign_key "notes", "users"
  add_foreign_key "organization_lead_roles", "vita_partners"
  add_foreign_key "outgoing_emails", "clients"
  add_foreign_key "outgoing_emails", "users"
  add_foreign_key "outgoing_text_messages", "clients"
  add_foreign_key "outgoing_text_messages", "users"
  add_foreign_key "recaptcha_scores", "clients"
  add_foreign_key "signup_selections", "users"
  add_foreign_key "site_coordinator_roles_vita_partners", "site_coordinator_roles"
  add_foreign_key "site_coordinator_roles_vita_partners", "vita_partners"
  add_foreign_key "source_parameters", "vita_partners"
  add_foreign_key "state_routing_fractions", "state_routing_targets"
  add_foreign_key "state_routing_fractions", "vita_partners"
  add_foreign_key "system_notes", "clients"
  add_foreign_key "system_notes", "users"
  add_foreign_key "tax_return_assignments", "tax_returns"
  add_foreign_key "tax_return_assignments", "users", column: "assigner_id"
  add_foreign_key "tax_return_selection_tax_returns", "tax_return_selections"
  add_foreign_key "tax_return_selection_tax_returns", "tax_returns"
  add_foreign_key "tax_return_transitions", "tax_returns"
  add_foreign_key "tax_returns", "clients"
  add_foreign_key "tax_returns", "users", column: "assigned_user_id"
  add_foreign_key "team_member_roles_vita_partners", "team_member_roles"
  add_foreign_key "team_member_roles_vita_partners", "vita_partners"
  add_foreign_key "user_notifications", "users"
  add_foreign_key "users", "users", column: "invited_by_id"
  add_foreign_key "verification_attempt_transitions", "verification_attempts"
  add_foreign_key "vita_partner_zip_codes", "vita_partners"
  add_foreign_key "vita_partners", "coalitions"
  add_foreign_key "vita_providers", "provider_scrapes", column: "last_scrape_id"
  add_foreign_key "w2_box14s", "w2s"
  add_foreign_key "w2_state_fields_groups", "w2s"
end
