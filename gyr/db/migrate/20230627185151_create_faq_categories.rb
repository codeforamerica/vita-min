class CreateFaqCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :faq_categories do |t|
      t.integer :position
      t.string :name_en
      t.string :name_es
      t.string :slug

      t.timestamps
    end
  end
end
