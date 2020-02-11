# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_11_213645) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "documents", force: :cascade do |t|
    t.string "document_type", null: false
    t.bigint "intake_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["intake_id"], name: "index_documents_on_intake_id"
  end

  create_table "intake_site_drop_offs", force: :cascade do |t|
    t.string "intake_site", null: false
    t.string "name", null: false
    t.string "email"
    t.string "phone_number"
    t.string "signature_method", null: false
    t.date "pickup_date"
    t.string "additional_info"
    t.string "timezone"
    t.string "certification_level"
    t.string "zendesk_ticket_id"
    t.bigint "prior_drop_off_id"
    t.boolean "hsa", default: false
    t.string "organization"
    t.string "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["prior_drop_off_id"], name: "index_intake_site_drop_offs_on_prior_drop_off_id"
  end

  create_table "intakes", force: :cascade do |t|
    t.integer "had_wages", default: 0, null: false
    t.integer "job_count"
    t.integer "had_tips", default: 0, null: false
    t.integer "had_retirement_income", default: 0, null: false
    t.integer "had_social_security_income", default: 0, null: false
    t.integer "had_unemployment_income", default: 0, null: false
    t.integer "had_disability_income", default: 0, null: false
    t.integer "had_interest_income", default: 0, null: false
    t.integer "had_asset_sale_income", default: 0, null: false
    t.integer "reported_asset_sale_loss", default: 0, null: false
    t.integer "received_alimony", default: 0, null: false
    t.integer "had_rental_income", default: 0, null: false
    t.integer "had_farm_income", default: 0, null: false
    t.integer "had_gambling_income", default: 0, null: false
    t.integer "had_local_tax_refund", default: 0, null: false
    t.integer "had_self_employment_income", default: 0, null: false
    t.integer "reported_self_employment_loss", default: 0, null: false
    t.integer "had_other_income", default: 0, null: false
    t.string "other_income_types"
    t.integer "paid_mortgage_interest", default: 0, null: false
    t.integer "paid_local_tax", default: 0, null: false
    t.integer "paid_medical_expenses", default: 0, null: false
    t.integer "paid_charitable_contributions", default: 0, null: false
    t.integer "paid_student_loan_interest", default: 0, null: false
    t.integer "paid_dependent_care", default: 0, null: false
    t.integer "paid_retirement_contributions", default: 0, null: false
    t.integer "paid_school_supplies", default: 0, null: false
    t.integer "paid_alimony", default: 0, null: false
    t.integer "had_student_in_family", default: 0, null: false
    t.integer "sold_a_home", default: 0, null: false
    t.integer "had_hsa", default: 0, null: false
    t.integer "bought_health_insurance", default: 0, null: false
    t.integer "received_homebuyer_credit", default: 0, null: false
    t.integer "had_debt_forgiven", default: 0, null: false
    t.integer "had_disaster_loss", default: 0, null: false
    t.integer "adopted_child", default: 0, null: false
    t.integer "had_tax_credit_disallowed", default: 0, null: false
    t.integer "received_irs_letter", default: 0, null: false
    t.integer "made_estimated_tax_payments", default: 0, null: false
    t.string "additional_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "married", default: 0, null: false
    t.integer "married_all_year", default: 0, null: false
    t.integer "lived_with_spouse", default: 0, null: false
    t.integer "separated", default: 0, null: false
    t.string "separated_year"
    t.integer "divorced", default: 0, null: false
    t.string "divorced_year"
    t.integer "widowed", default: 0, null: false
    t.string "widowed_year"
    t.integer "filing_joint", default: 0, null: false
    t.string "source"
    t.string "referrer"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.bigint "intake_ticket_requester_id"
    t.bigint "intake_ticket_id"
    t.string "interview_timing_preference"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid"
    t.string "provider"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "intake_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "birth_date"
    t.string "ssn"
    t.string "phone_number"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "is_spouse", default: false
    t.integer "sms_notification_opt_in", default: 0, null: false
    t.integer "email_notification_opt_in", default: 0, null: false
    t.index ["intake_id"], name: "index_users_on_intake_id"
  end

  create_table "vita_providers", force: :cascade do |t|
    t.string "name"
    t.string "irs_id", null: false
    t.string "details"
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "dates"
    t.string "hours"
    t.string "languages"
    t.string "appointment_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["irs_id"], name: "index_vita_providers_on_irs_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "intake_site_drop_offs", "intake_site_drop_offs", column: "prior_drop_off_id"
  add_foreign_key "users", "intakes"
end
