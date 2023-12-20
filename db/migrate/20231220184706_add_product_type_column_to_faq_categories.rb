class AddProductTypeColumnToFaqCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :faq_categories, :product_type, :integer, default: 0, null: false
  end
end
