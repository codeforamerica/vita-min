class AddPhoneNumberMetadataFieldsToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :phone_number_type, :string
    add_column :intakes, :phone_carrier, :string
  end
end
