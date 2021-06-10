class CreateEfileSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :efile_submissions do |t|
      t.references :tax_return
    end
  end
end
