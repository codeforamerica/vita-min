class AddHadW2sToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :had_w2s, :integer, default: 0, null: false
  end
end
