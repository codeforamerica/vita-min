class AddFiledStatusesToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :filed_2020, :integer, default: 0, null: false
    add_column :intakes, :filed_2019, :integer, default: 0, null: false
  end
end
