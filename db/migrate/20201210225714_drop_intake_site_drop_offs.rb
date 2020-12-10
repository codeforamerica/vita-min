class DropIntakeSiteDropOffs < ActiveRecord::Migration[6.0]
  def change
    drop_table :intake_site_drop_offs
  end
end
