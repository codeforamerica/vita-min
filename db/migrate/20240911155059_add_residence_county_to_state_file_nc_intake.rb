class AddResidenceCountyToStateFileNcIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :residence_county, :string, null: false, default: "unfilled"
  end
end
