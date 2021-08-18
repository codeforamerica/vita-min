class AddAutoCancelToEfileErrors < ActiveRecord::Migration[6.0]
  def change
    add_column :efile_errors, :auto_cancel, :boolean, default: false
  end
end
