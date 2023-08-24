class DropStimulusTriage < ActiveRecord::Migration[6.0]
  def change
    drop_table :stimulus_triages
    remove_column :intakes, :triage_source_type, :string
    remove_column :intakes, :triage_source_id, :integer
  end
end
