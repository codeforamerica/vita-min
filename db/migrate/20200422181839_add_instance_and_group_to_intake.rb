class AddInstanceAndGroupToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :zendesk_instance_domain, :string
    add_column :intakes, :zendesk_group_id, :string
  end
end
