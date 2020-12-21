class AddPhoneNumberToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :phone_number, :string, null: true
  end
end
