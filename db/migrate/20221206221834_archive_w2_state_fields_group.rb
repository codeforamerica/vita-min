class ArchiveW2StateFieldsGroup < ActiveRecord::Migration[7.0]
  rename_index :w2_state_fields_groups, "index_w2_state_fields_groups_on_w2_id", "index_arc_w2_sfg_2022_on_arc_w2_2022_id"

  safety_assured do
    rename_table :w2_state_fields_groups, :archived_w2_state_fields_groups_2022
    rename_column :archived_w2_state_fields_groups_2022, :w2_id, :archived_w2s_2022_id
  end
end
