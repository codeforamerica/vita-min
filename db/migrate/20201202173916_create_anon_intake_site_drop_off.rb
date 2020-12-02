class CreateAnonIntakeSiteDropOff < ActiveRecord::Migration[6.0]
  def change
    create_table :anon_intake_site_drop_offs do |t|
      t.bigint :original_id, null: false
      t.string :intake_site, null: false
      t.string :pickup_method, null: false
      t.date :pickup_date
      t.string :additional_info
      t.string :certification_level
      t.boolean :hsa
      t.string :organization
      t.string :signature_method
      t.string :state
      t.string :timezone
      t.datetime :original_created_at
      t.datetime :original_updated_at
      t.bigint :prior_drop_off_id
      t.string :zendesk_ticket_id
    end
  end
end
