class RemoveZendeskPropertiesAndDisplayNameFromVitaPartner < ActiveRecord::Migration[6.0]
  def change
    remove_column :vita_partners, :zendesk_instance_domain
    remove_column :vita_partners, :zendesk_group_id
    remove_column :vita_partners, :display_name
    remove_column :intakes, :vita_partner_group_id
    remove_column :intakes, :zendesk_instance_domain
  end
end
