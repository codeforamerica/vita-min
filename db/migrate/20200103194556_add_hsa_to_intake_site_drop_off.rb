class AddHsaToIntakeSiteDropOff < ActiveRecord::Migration[5.2]
  def change
    add_column :intake_site_drop_offs, :hsa, :boolean, default: false
  end
end
