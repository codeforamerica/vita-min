class RemoveSourceParameterFromVitaPartner < ActiveRecord::Migration[6.0]
  def change
    # Removes source_parameter attribute because we now use a relationship to the SourceParameter model
    remove_column :vita_partners, :source_parameter, :string
  end
end
