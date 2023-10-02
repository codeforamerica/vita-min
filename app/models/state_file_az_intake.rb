# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                   :bigint           not null, primary key
#  claimed_as_dep       :integer
#  current_step         :string
#  raw_direct_file_data :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  visitor_id           :string
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
