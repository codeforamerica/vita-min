class AddTokenToDiyIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :diy_intakes, :token, :string
    add_index :diy_intakes, :token, unique: true
  end
end
