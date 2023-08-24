class CreateEfileErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :efile_errors do |t|
      t.timestamps
      t.string :code
      t.text :message
      t.string :category
      t.string :severity
      t.string :source
      t.boolean :expose, default: true
    end
  end
end
