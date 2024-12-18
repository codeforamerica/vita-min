class AddCountyFieldsToStateFileMdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :residence_county, :string
    add_column :state_file_md_intakes, :political_subdivision, :string
    add_column :state_file_md_intakes, :subdivision_code, :string
  end
end
