class AddWagesAndEmployerEinToStateFileW2 < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_w2s, :wages, :decimal, precision: 12, scale: 2
    add_column :state_file_w2s, :employer_ein, :string
  end
end
