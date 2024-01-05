class AddDescriptionToFaqCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :faq_categories, :description_en, :text
    add_column :faq_categories, :description_es, :text
  end
end
