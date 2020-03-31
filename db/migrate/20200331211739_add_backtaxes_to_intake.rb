class AddBacktaxesToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :needs_help_2016, :integer, default: 0, null: false
    add_column :intakes, :needs_help_2017, :integer, default: 0, null: false
    add_column :intakes, :needs_help_2018, :integer, default: 0, null: false
    add_column :intakes, :needs_help_2019, :integer, default: 0, null: false
  end
end
