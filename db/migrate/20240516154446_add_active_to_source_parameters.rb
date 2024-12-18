class AddActiveToSourceParameters < ActiveRecord::Migration[7.1]
  def change
    add_column :source_parameters, :active, :boolean, null: false, default: true
  end
end
