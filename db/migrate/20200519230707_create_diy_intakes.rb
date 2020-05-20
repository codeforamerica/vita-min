class CreateDiyIntakes < ActiveRecord::Migration[6.0]
  def change
    create_table :diy_intakes do |t|
      t.string :preferred_name
      t.string :state_of_residence

      t.timestamps
    end
  end
end
