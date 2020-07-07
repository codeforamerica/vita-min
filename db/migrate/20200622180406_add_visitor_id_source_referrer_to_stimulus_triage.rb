class AddVisitorIdSourceReferrerToStimulusTriage < ActiveRecord::Migration[6.0]
  def change
    add_column :stimulus_triages, :visitor_id, :string
    add_column :stimulus_triages, :source, :string
    add_column :stimulus_triages, :referrer, :string
  end
end
