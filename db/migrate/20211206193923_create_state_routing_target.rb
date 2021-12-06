class CreateStateRoutingTarget < ActiveRecord::Migration[6.1]
  def change
    create_table :state_routing_targets do |t|
      t.string :state_abbreviation, null: false, index: true
      t.references :target,null: false, polymorphic: true, index: true
      t.timestamps
    end
  end
end
