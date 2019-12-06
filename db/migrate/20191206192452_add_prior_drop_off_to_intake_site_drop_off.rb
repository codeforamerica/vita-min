class AddPriorDropOffToIntakeSiteDropOff < ActiveRecord::Migration[5.2]
  def change
    add_reference :intake_site_drop_offs, :prior_drop_off, foreign_key: { to_table: :intake_site_drop_offs }
  end
end
