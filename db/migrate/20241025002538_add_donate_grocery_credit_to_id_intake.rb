class AddDonateGroceryCreditToIdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :donate_grocery_credit, :integer, default: 0, null: false
  end
end
