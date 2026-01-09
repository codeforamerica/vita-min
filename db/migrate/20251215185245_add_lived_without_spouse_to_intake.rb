class AddLivedWithoutSpouseToIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :lived_without_spouse, :integer, default: 0, null: false
  end
end
