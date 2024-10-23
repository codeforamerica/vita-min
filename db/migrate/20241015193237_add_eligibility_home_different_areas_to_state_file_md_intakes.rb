class AddEligibilityHomeDifferentAreasToStateFileMdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :eligibility_home_different_areas, :integer, null: false, default: 0
  end
end
