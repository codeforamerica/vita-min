class CreateExperimentParticipants < ActiveRecord::Migration[7.0]
  def change
    create_table :experiment_participants do |t|
      t.references :experiment
      t.references :record, polymorphic: true, null: false
      t.string :treatment

      t.timestamps
    end
  end
end
