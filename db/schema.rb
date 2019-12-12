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

ActiveRecord::Schema.define(version: 2019_12_13_185516) do

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
    t.index ["prior_drop_off_id"], name: "index_intake_site_drop_offs_on_prior_drop_off_id"
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
    t.index ["irs_id"], name: "index_vita_providers_on_irs_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "intake_site_drop_offs", "intake_site_drop_offs", column: "prior_drop_off_id"
end
