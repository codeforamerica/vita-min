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
  def tax_calculator(include_source: false)
    Efile::Az::Az140.new(
      year: 2022,
      filing_status: filing_status.to_sym,
      claimed_as_dependent: claimed_as_dep_yes?,
      dependent_count: dependents.length,
      direct_file_data: direct_file_data,
      include_source: include_source
    )
  end
end
