class AddRetirementFieldsToNjAnalytics < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_analytics, :NJ1040_LINE_20A, :integer, default: 0, null: false
    add_column :state_file_nj_analytics, :NJ1040_LINE_20B, :integer, default: 0, null: false
    add_column :state_file_nj_analytics, :NJ1040_LINE_28A, :integer, default: 0, null: false
    add_column :state_file_nj_analytics, :NJ1040_LINE_28B, :integer, default: 0, null: false
    add_column :state_file_nj_analytics, :NJ1040_LINE_28C, :integer, default: 0, null: false
  end
end
