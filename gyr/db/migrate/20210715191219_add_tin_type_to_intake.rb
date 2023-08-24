class AddTinTypeToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :tin_type, :integer
  end
end
