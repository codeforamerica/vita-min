class CreateExperimentVitaPartners < ActiveRecord::Migration[7.0]
  def change
    create_table :experiment_vita_partners do |t|
      t.references :experiment, null: false, foreign_key: true
      t.references :vita_partner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
