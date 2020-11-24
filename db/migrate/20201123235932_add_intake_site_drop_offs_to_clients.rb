class AddIntakeSiteDropOffsToClients < ActiveRecord::Migration[6.0]
  def change
    add_reference :intake_site_drop_offs, :client, foreign_key: true
  end
end
