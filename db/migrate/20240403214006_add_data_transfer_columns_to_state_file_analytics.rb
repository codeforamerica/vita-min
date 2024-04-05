class AddDataTransferColumnsToStateFileAnalytics < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_analytics, :initiate_data_transfer_first_visit_at, :datetime
    add_column :state_file_analytics, :name_dob_first_visit_at, :datetime
    add_column :state_file_analytics, :canceled_data_transfer_count, :integer, default: 0
    add_column :state_file_analytics, :initiate_df_data_transfer_clicks, :integer, default: 0
  end
end
