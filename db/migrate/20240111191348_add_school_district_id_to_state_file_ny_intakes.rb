class AddSchoolDistrictIdToStateFileNyIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :school_district_id, :integer, null: true
  end
end
