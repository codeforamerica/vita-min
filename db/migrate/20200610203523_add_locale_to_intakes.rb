class AddLocaleToIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :locale, :string
  end
end
