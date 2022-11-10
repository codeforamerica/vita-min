class RemoveFullTimeStudentLessThanFourMonthsfromIntake < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :intakes, :full_time_student_less_than_four_months }
  end
end
