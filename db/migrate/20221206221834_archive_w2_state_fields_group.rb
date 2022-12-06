class ArchiveW2StateFieldsGroup < ActiveRecord::Migration[7.0]
  def change
    columns = %w[
      box15_employer_state_id_number
      box15_state
      box16_state_wages
      box17_state_income_tax
      box18_local_wages
      box19_local_income_tax
      box20_locality_name
      created_at
      updated_at
      w2_id
    ]
    columns.each do |column|
      rename_index :intakes, "index_w2_state_fields_groups_on_#{column}", "index_arc_w2_state_2022_on_#{column}"
    end

    safety_assured do
      rename_table :w2_state_fields_groups, :archived_w2_state_fields_groups_2022
      rename_column :archived_w2_state_fields_groups_2022, :w2_id, :archived_w2s_2022_id
    end
  end
end
