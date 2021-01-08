class DeleteUsersVitaPartners < ActiveRecord::Migration[6.0]
  def change
    drop_table :users_vita_partners
  end
end
