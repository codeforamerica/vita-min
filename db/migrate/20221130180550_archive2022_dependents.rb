class Archive2022Dependents < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_table :dependents, :archived_dependents_2022
      rename_column :archived_dependents_2022, :intake_id, :archived_intakes_2022_id
    end
  end
end
