# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                     :bigint           not null, primary key
#  bank_account_number    :string
#  bank_account_type      :integer
#  bank_routing_number    :string
#  charitable_cash        :integer
#  charitable_noncash     :integer
#  claimed_as_dep         :integer
#  current_step           :string
#  primary_first_name     :string
#  primary_last_name      :string
#  primary_middle_initial :string
#  prior_last_names       :string
#  raw_direct_file_data   :text
#  spouse_first_name      :string
#  spouse_last_name       :string
#  spouse_middle_initial  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  visitor_id             :string
#
class StateFileAzIntake < StateFileBaseIntake

  enum bank_account_type: { unfilled: 0, checking: 1, savings: 2, unspecified: 3 }, _prefix: :bank_account_type
  def tax_calculator(include_source: false)
    Efile::Az::Az140.new(
      year: 2022,
      filing_status: filing_status.to_sym,
      claimed_as_dependent: claimed_as_dep_yes?,
      intake: self,
      dependent_count: dependents.length,
      federal_dependent_count_under_17: 2, #todo: change, is this from 1040? waiting for response
      federal_dependent_count_over_17: 1, #todo: will they give us the number or do we calculate based on certain date
      sentenced_for_60_days: false, # todo: ask this question
      direct_file_data: direct_file_data,
      include_source: include_source,
    )
  end
end
