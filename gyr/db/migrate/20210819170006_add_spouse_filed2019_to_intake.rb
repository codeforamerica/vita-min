class AddSpouseFiled2019ToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :spouse_filed_2019, :integer, default: 0, null: false
  end
end
