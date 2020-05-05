class CreateStates < ActiveRecord::Migration[6.0]
  def change
    create_table :states, id: false do |t|
      t.string :name
      t.string :abbreviation, primary_key: true

      t.timestamps
    end
    add_index :states, :name

    create_table :states_vita_partners, id: false do |t|
      t.string :state_abbreviation, required: true, index: true
      t.references :vita_partner, foreign_key: true
    end
  end
end
