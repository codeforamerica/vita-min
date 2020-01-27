class AddIntakeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :intake, foreign_key: true, null: false
  end
end
