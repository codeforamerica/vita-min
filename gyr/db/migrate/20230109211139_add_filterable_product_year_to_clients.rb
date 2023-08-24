class AddFilterableProductYearToClients < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :filterable_product_year, :integer
  end
end
