class AddAutoWaitToErrors < ActiveRecord::Migration[6.0]
  def change
    add_column :efile_errors, :auto_wait, :boolean, default: false
  end
end
