class AddFedIncomeTotalToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :fed_income_total, :integer
  end
end
