class AddNeedItinHelpToIntakes < ActiveRecord::Migration[6.1]
  def change
    add_column :intakes, :need_itin_help, :integer, default: 0, null: false
  end
end
