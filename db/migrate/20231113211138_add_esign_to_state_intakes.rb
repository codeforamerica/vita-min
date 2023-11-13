class AddEsignToStateIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :primary_esigned, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :primary_esigned_at, :datetime
    add_column :state_file_az_intakes, :primary_esigned, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :primary_esigned_at, :datetime

    add_column :state_file_ny_intakes, :spouse_esigned, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :spouse_esigned_at, :datetime
    add_column :state_file_az_intakes, :spouse_esigned, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :spouse_esigned_at, :datetime
  end
end
