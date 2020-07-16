class AddFeedbackToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :feedback, :string
  end
end
