class AddTinTypeToDependent < ActiveRecord::Migration[6.0]
  def change
    add_column :dependents, :tin_type, :integer
  end
end
