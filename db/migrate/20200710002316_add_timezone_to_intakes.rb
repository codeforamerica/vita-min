class AddTimezoneToIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :timezone, :string
  end
end
