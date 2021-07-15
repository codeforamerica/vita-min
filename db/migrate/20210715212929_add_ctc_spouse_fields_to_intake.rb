class AddCtcSpouseFieldsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :spouse_middle_initial, :string
    add_column :intakes, :spouse_tin_type, :integer
    add_column :intakes, :spouse_veteran, :integer, default: 0
  end
end
