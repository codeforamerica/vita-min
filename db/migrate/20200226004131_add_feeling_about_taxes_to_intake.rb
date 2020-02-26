class AddFeelingAboutTaxesToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :feeling_about_taxes, :integer, default: 0, null: false
  end
end
