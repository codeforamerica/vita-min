class AddEsignedAtToStateFileNcIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :primary_esigned_at, :timestamp
    add_column :state_file_nc_intakes, :spouse_esigned_at, :timestamp
  end
end
