class AddPrimaryVisaAndSpouseVisaToGyrIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :primary_visa, :integer, default: 0, null: false
    add_column :intakes, :spouse_visa, :integer, default: 0, null: false
  end
end
