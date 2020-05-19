class RenameZendeskGroupIdOnIntake < ActiveRecord::Migration[6.0]
  def change
    rename_column :intakes, :zendesk_group_id, :vita_partner_group_id
    add_column :intakes, :routed_at, :datetime
    add_column :intakes, :routing_criteria, :string
    add_column :intakes, :routing_value, :string
  end
end
