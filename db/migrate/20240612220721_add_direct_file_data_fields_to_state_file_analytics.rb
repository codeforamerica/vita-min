class AddDirectFileDataFieldsToStateFileAnalytics < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_analytics, :fed_refund_amt, :integer
    add_column :state_file_analytics, :zip_code, :string
  end
end
