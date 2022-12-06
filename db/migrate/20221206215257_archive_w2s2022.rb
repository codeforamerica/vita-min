class ArchiveW2s2022 < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_table :w2s, :archived_w2s_2022
      rename_column :archived_w2s_2022, :intake_id, :archived_intakes_2022_id
    end
  end
end
