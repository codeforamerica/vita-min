class AddWagesAmtToStateFileW2s < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_w2s, :wages_amt, :integer
  end
end
