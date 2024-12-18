class AddCountyAndMunicipalityToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :county, :string
    add_column :state_file_nj_intakes, :municipality_name, :string
    add_column :state_file_nj_intakes, :municipality_code, :string
  end
end
