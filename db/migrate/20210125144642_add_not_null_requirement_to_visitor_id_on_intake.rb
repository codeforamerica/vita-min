class AddNotNullRequirementToVisitorIdOnIntake < ActiveRecord::Migration[6.0]
  def up
    change_column_null :intakes, :visitor_id, false
  end

  def down
    change_column_null :intakes, :visitor_id, true
  end
end
