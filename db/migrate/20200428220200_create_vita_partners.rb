class CreateVitaPartners < ActiveRecord::Migration[6.0]
  def change
    create_table :vita_partners do |t|
      t.string :name, null: false
      t.string :logo_url
      t.string :zendesk_group_id, null: false
      t.string :zendesk_instance_domain, null: false

      t.timestamps
    end

    add_reference :intakes, :vita_partner, foreign_key: true
  end
end
