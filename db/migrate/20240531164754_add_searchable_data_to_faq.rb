class AddSearchableDataToFaq < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :faq_items, :searchable_data_en, :tsvector
    add_column :faq_items, :searchable_data_es, :tsvector
    add_index :faq_items, :searchable_data_en, using: :gin, algorithm: :concurrently
    add_index :faq_items, :searchable_data_es, using: :gin, algorithm: :concurrently
    begin
      # Using models in migrations is bad practice, but this is obnoxious and I could find no other way:
      #
      # We can't do this in pure SQL because `plain_text` is not implemented in SQL - it is in rails
      # Actually the searchable_data_en/es is not even stored in the faq_items table - If we try to
      # use a temporary model, the relation with the table does not work.
      #
      # We also can't do it in pure rails because the `to_tsvector` is not implemented in rails - it
      # is SQL functionality.
      #
      # So we either do this here, or we implement a rake task that is run after the migration. I
      # figured this was easiest.
      #
      FaqItem.all.each do |faq_item|
        faq_item.update_searchable_attrs
      end
    rescue Exception => e
      puts e
    end
  end
end
