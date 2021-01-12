class DropStatesTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :states, id: false do |t|
      t.string :name
      t.string :abbreviation, primary_key: true
    end
  end
end
