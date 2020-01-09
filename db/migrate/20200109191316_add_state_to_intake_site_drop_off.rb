class AddStateToIntakeSiteDropOff < ActiveRecord::Migration[5.2]
  def change
    add_column :intake_site_drop_offs, :state, :string
  end
end
