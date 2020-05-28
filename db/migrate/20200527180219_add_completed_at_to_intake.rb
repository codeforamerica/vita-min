class AddCompletedAtToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :completed_at, :datetime
  end
end
