class AddTimestampsToIntakeSiteDropOffs < ActiveRecord::Migration[5.2]
  def change
    add_column :intake_site_drop_offs, :created_at, :datetime
    add_column :intake_site_drop_offs, :updated_at, :datetime
  end
end
