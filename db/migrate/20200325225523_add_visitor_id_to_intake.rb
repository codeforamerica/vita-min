class AddVisitorIdToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :visitor_id, :string
  end
end
