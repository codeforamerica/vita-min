class AddSourceAndReferrerToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :source, :string
    add_column :intakes, :referrer, :string
  end
end
