class DropIdmeUsers < ActiveRecord::Migration[6.0]
  def change
    drop_table :idme_users
  end
end
