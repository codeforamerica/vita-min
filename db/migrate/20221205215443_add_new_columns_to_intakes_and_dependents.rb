class AddNewColumnsToIntakesAndDependents < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :primary_us_citizen, :integer, default: 0, null: false
    add_column :intakes, :spouse_us_citizen, :integer, default: 0, null: false
    add_column :intakes, :spouse_phone_number, :string
    add_column :intakes, :primary_job_title, :string
    add_column :intakes, :spouse_job_title, :string
    add_column :intakes, :got_married_during_tax_year, :integer, default: 0, null: false

    add_column :dependents, :filer_provided_over_half_housing_support, :integer, default: 0, null: false
  end
end
