class AddTimestampsToIntakes < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :created_at, :datetime
    add_column :intakes, :updated_at, :datetime
  end
end
