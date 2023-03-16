class AddColumnsToDiyIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :diy_intakes, :preferred_first_name, :string
    add_column :diy_intakes, :received_1099, :integer, default: 0, null: false
    add_column :diy_intakes, :filing_frequency, :integer, default: 0, null: false
  end
end
