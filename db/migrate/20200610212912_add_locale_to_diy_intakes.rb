class AddLocaleToDiyIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :diy_intakes, :locale, :string
  end
end
