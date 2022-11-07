class AddFullTimeStudentLessThanFiveMonthsToIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :full_time_student_less_than_five_months, :integer, default: 0, null: false
  end
end
