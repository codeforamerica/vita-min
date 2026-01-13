class CreateCampaignContact < ActiveRecord::Migration[7.1]
  def change
    enable_extension "citext" unless extension_enabled?("citext")

    create_table :campaign_contacts do |t|
      t.string :first_name, null: false
      t.string :last_name

      # associations
      t.jsonb :state_file_intake_refs, null: false, default: []
      t.bigint :gyr_intake_ids, array: true, default: []
      t.bigint :sign_up_ids, array: true, default: []

      t.citext :email_address
      t.string :sms_phone_number

      t.boolean :email_notification_opt_in, default: false
      t.boolean :sms_notification_opt_in, default: false

      t.string :locale

      t.datetime :gyr_2025_preseason_email
      t.datetime :gyr_2025_preseason_sms

      t.timestamps
    end

    add_index :campaign_contacts, :email_address, unique: true, where: "email_address IS NOT NULL"
    add_index :campaign_contacts, :sms_phone_number
    add_index :campaign_contacts, [:first_name, :last_name]
    add_index :campaign_contacts, :state_file_intake_refs, using: :gin
    add_index :campaign_contacts, :gyr_intake_ids, using: :gin
    add_index :campaign_contacts, :sign_up_ids, using: :gin
    add_index :campaign_contacts, :email_notification_opt_in
    add_index :campaign_contacts, :sms_notification_opt_in
  end
end
