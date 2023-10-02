# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                     :bigint           not null, primary key
#  claimed_as_dep         :integer
#  current_step           :string
#  primary_first_name     :string
#  primary_last_name      :string
#  primary_middle_initial :string
#  raw_direct_file_data   :text
#  spouse_first_name      :string
#  spouse_last_name       :string
#  spouse_middle_initial  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  visitor_id             :string
#
class StateFileAzIntake < StateFileBaseIntake
  def tax_calculator
    field_by_line_id = {
      AMT_12: [self.direct_file_data, :fed_agi],
    }
    input_lines = {}
    field_by_line_id.each do |line_id, value|
      input_lines[line_id] =
        if value.is_a?(Array)
          source, field = value
          Efile::TaxFormLine.from_data_source(line_id, source, field)
        else
          Efile::TaxFormLine.new(line_id, value, "Static", [])
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
