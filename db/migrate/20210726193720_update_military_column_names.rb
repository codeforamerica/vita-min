class UpdateMilitaryColumnNames < ActiveRecord::Migration[6.0]
  def change
    rename_column :intakes, :primary_member_of_the_armed_forces, :primary_active_armed_forces
    rename_column :intakes, :spouse_veteran, :spouse_active_armed_forces
    rename_column :intakes, :tin_type, :primary_tin_type
  end
end
