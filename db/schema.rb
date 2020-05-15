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

ActiveRecord::Schema.define(version: 2020_05_14_214915) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

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

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document_type", null: false
    t.bigint "documents_request_id"
    t.bigint "intake_id"
    t.datetime "updated_at", null: false
    t.bigint "zendesk_ticket_id"
    t.index ["documents_request_id"], name: "index_documents_on_documents_request_id"
    t.index ["intake_id"], name: "index_documents_on_intake_id"
  end

  create_table "documents_requests", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.bigint "intake_id"
    t.datetime "updated_at", precision: 6, null: false
    t.index ["intake_id"], name: "index_documents_requests_on_intake_id"
  end

  create_table "intake_site_drop_offs", force: :cascade do |t|
    t.string "additional_info"
    t.string "certification_level"
    t.datetime "created_at"
    t.string "email"
    t.boolean "hsa", default: false
    t.string "intake_site", null: false
    t.string "name", null: false
    t.string "organization"
    t.string "phone_number"
    t.date "pickup_date"
    t.bigint "prior_drop_off_id"
    t.string "signature_method", null: false
    t.string "state"
    t.string "timezone"
    t.datetime "updated_at"
    t.string "zendesk_ticket_id"
    t.index ["prior_drop_off_id"], name: "index_intake_site_drop_offs_on_prior_drop_off_id"
  end

  create_table "intakes", force: :cascade do |t|
    t.string "additional_info"
    t.integer "adopted_child", default: 0, null: false
    t.integer "already_filed", default: 0, null: false
    t.boolean "anonymous", default: false, null: false
    t.integer "balance_pay_from_bank", default: 0, null: false
    t.integer "bank_account_type", default: 0, null: false
    t.integer "bought_energy_efficient_items"
    t.integer "bought_health_insurance", default: 0, null: false
    t.string "city"
    t.boolean "completed_intake_sent_to_zendesk"
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
    t.integer "had_student_in_family", default: 0, null: false
    t.integer "had_tax_credit_disallowed", default: 0, null: false
    t.integer "had_tips", default: 0, null: false
    t.integer "had_unemployment_income", default: 0, null: false
    t.integer "had_wages", default: 0, null: false
    t.integer "income_over_limit", default: 0, null: false
    t.boolean "intake_pdf_sent_to_zendesk", default: false, null: false
    t.bigint "intake_ticket_id"
    t.bigint "intake_ticket_requester_id"
    t.string "interview_timing_preference"
    t.integer "issued_identity_pin", default: 0, null: false
    t.integer "job_count"
    t.integer "lived_with_spouse", default: 0, null: false
    t.integer "made_estimated_tax_payments", default: 0, null: false
    t.integer "married", default: 0, null: false
    t.integer "multiple_states", default: 0, null: false
    t.integer "needs_help_2016", default: 0, null: false
    t.integer "needs_help_2017", default: 0, null: false
    t.integer "needs_help_2018", default: 0, null: false
    t.integer "needs_help_2019", default: 0, null: false
    t.integer "no_eligibility_checks_apply", default: 0, null: false
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
    t.string "preferred_name"
    t.date "primary_birth_date"
    t.integer "primary_consented_to_service", default: 0, null: false
    t.datetime "primary_consented_to_service_at"
    t.inet "primary_consented_to_service_ip"
    t.string "primary_first_name"
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
    t.integer "savings_purchase_bond", default: 0, null: false
    t.integer "savings_split_refund", default: 0, null: false
    t.integer "separated", default: 0, null: false
    t.string "separated_year"
    t.integer "sms_notification_opt_in", default: 0, null: false
    t.string "sms_phone_number"
    t.integer "sold_a_home", default: 0, null: false
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
    t.datetime "updated_at"
    t.string "visitor_id"
    t.bigint "vita_partner_id"
    t.string "vita_partner_name"
    t.integer "was_blind", default: 0, null: false
    t.integer "was_full_time_student", default: 0, null: false
    t.integer "was_on_visa", default: 0, null: false
    t.integer "widowed", default: 0, null: false
    t.string "widowed_year"
    t.string "zendesk_group_id"
    t.string "zendesk_instance_domain"
    t.string "zip_code"
    t.index ["vita_partner_id"], name: "index_intakes_on_vita_partner_id"
  end

  create_table "provider_scrapes", force: :cascade do |t|
    t.integer "archived_count", default: 0, null: false
    t.integer "changed_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "created_count", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "ticket_statuses", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.bigint "intake_id"
    t.string "intake_status", null: false
    t.string "return_status", null: false
    t.integer "ticket_id"
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "verified_change", default: true
    t.index ["intake_id"], name: "index_ticket_statuses_on_intake_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "birth_date"
    t.string "city"
    t.integer "consented_to_service", default: 0, null: false
    t.datetime "consented_to_service_at"
    t.string "consented_to_service_ip"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.inet "current_sign_in_ip"
    t.string "email"
    t.integer "email_notification_opt_in", default: 0, null: false
    t.string "encrypted_ssn"
    t.string "encrypted_ssn_iv"
    t.string "first_name"
    t.bigint "intake_id", null: false
    t.boolean "is_spouse", default: false
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.inet "last_sign_in_ip"
    t.string "phone_number"
    t.string "provider"
    t.integer "sign_in_count", default: 0, null: false
    t.integer "sms_notification_opt_in", default: 0, null: false
    t.string "state"
    t.string "street_address"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["intake_id"], name: "index_users_on_intake_id"
  end

  create_table "vita_partners", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.string "display_name"
    t.string "logo_path"
    t.string "name", null: false
    t.string "source_parameter"
    t.datetime "updated_at", precision: 6, null: false
    t.string "zendesk_group_id", null: false
    t.string "zendesk_instance_domain", null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "documents", "documents_requests"
  add_foreign_key "documents_requests", "intakes"
  add_foreign_key "intake_site_drop_offs", "intake_site_drop_offs", column: "prior_drop_off_id"
  add_foreign_key "intakes", "vita_partners"
  add_foreign_key "ticket_statuses", "intakes"
  add_foreign_key "users", "intakes"
  add_foreign_key "vita_providers", "provider_scrapes", column: "last_scrape_id"
end
