class AddPayerName2ToStateFile1099Rs < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file1099_rs, :payer_name2, :string
  end
end
