class CreateContents < ActiveRecord::Migration[7.0]
  def change
    create_table :contents do |t|
      t.string :name
      t.string :pathname
      t.boolean :is_faq
      t.timestamp :activated_at
      t.timestamps
    end
  end
end
