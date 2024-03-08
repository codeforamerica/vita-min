class AddProductTypeColumnToEfileErrors < ActiveRecord::Migration[7.1]
  def change
    add_column :efile_errors, :service_type, :integer, default: 0, null: false
  end
end
