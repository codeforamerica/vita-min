class AddDemographicPrimaryMenaToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :demographic_primary_mena, :boolean
  end
end
