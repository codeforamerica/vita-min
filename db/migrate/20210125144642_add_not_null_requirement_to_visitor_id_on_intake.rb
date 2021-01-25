class AddNotNullRequirementToVisitorIdOnIntake < ActiveRecord::Migration[6.0]
  def change
    change_column_null :intakes, :visitor_id, false
  end
end
