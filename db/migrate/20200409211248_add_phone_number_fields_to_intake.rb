class AddPhoneNumberFieldsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :phone_number, :string
    add_column :intakes, :phone_number_can_receive_texts, :integer, null: false, default: 0
  end
end
