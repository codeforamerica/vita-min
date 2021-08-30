class AddPriorYearSignaturePinToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :primary_prior_year_signature_pin, :string
    add_column :intakes, :spouse_prior_year_signature_pin, :string
  end
end
