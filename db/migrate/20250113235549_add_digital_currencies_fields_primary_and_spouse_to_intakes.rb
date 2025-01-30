class AddDigitalCurrenciesFieldsPrimaryAndSpouseToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :primary_owned_or_held_any_digital_currencies, :integer, default: 0, null: false
    add_column :intakes, :spouse_owned_or_held_any_digital_currencies, :integer, default: 0, null: false
  end
end
