class CreateEfileSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :efile_submissions do |t|
      t.references :tax_return
      t.timestamps
    end
  end
end
