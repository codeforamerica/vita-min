class AddUrbanizationToIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :urbanization, :string
  end
end
