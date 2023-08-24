class AddCompletedAtToW2s < ActiveRecord::Migration[7.0]
  def change
    add_column :w2s, :completed_at, :datetime
  end
end
