class AddDemographicSpouseMenaToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :demographic_spouse_mena, :boolean
  end
end
