# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                             :bigint           not null, primary key
#  claimed_as_dep                 :integer
#  current_step                   :string
#  fed_taxable_income             :integer
#  fed_taxable_ssb                :integer
#  fed_unemployment               :integer
#  fed_wages                      :integer
#  filing_status                  :integer
#  mailing_apartment              :string
#  mailing_city                   :string
#  mailing_street                 :string
#  mailing_zip                    :string
#  phone_daytime                  :string
#  phone_daytime_area_code        :string
#  primary_dob                    :date
#  primary_first_name             :string
#  primary_last_name              :string
#  primary_middle_initial         :string
#  primary_occupation             :string
#  primary_ssn                    :string
#  spouse_dob                     :date
#  spouse_first_name              :string
#  spouse_last_name               :string
#  spouse_middle_initial          :string
#  spouse_occupation              :string
#  spouse_ssn                     :string
#  tax_return_year                :integer
#  total_fed_adjustments          :integer
#  total_fed_adjustments_identify :string
#  total_state_tax_withheld       :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  visitor_id                     :string
#
class StateFileAzIntake < StateFileBaseIntake
  def fed_agi
    # TODO: When we store XML, delete the arithmetic and rely on the fed AGI in the XML.
    [fed_wages, fed_taxable_income, fed_unemployment, fed_taxable_ssb].compact.sum
  end

  def tax_calculator
    field_by_line_id = {
      AMT_12: :fed_agi
    }
    input_lines = {}
    field_by_line_id.each do |line_id, field|
      input_lines[line_id] =
        if field.is_a?(Symbol)
          Efile::TaxFormLine.from_data_source(line_id, self, field)
        else
          Efile::TaxFormLine.new(line_id, field, "Static", [])
        end
    end
    Efile::Az::Az140.new(
      year: 2022,
      filing_status: filing_status.to_sym,
      claimed_as_dependent: claimed_as_dep_yes?,
      dependent_count: dependents.length,
      input_lines: input_lines,
    )
  end
end
