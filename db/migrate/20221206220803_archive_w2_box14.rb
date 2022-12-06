class ArchiveW2Box14 < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_table :w2_box14s, :archived_w2_box14s_2022
      rename_column :archived_w2_box14s_2022, :w2_id, :archived_w2s_2022_id
    end
  end
end
