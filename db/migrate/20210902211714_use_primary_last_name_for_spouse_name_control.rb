class UsePrimaryLastNameForSpouseNameControl < ActiveRecord::Migration[6.0]
  def change
    rename_column :intakes, :use_spouse_name_for_name_control, :use_primary_name_for_name_control
    change_column_default :intakes, :use_primary_name_for_name_control, false
  end
end
