class AddEitcQualifiersToCtcIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :former_foster_youth, :integer, default: 0, null: false
    add_column :intakes, :homeless_youth, :integer, default: 0, null: false
    add_column :intakes, :not_full_time_student, :integer, default: 0, null: false
    add_column :intakes, :full_time_student_less_than_four_months, :integer, default: 0, null: false
  end
end
