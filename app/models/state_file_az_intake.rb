# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                     :bigint           not null, primary key
#  bank_account_number    :string
#  bank_account_type      :integer
#  bank_routing_number    :string
#  charitable_cash        :integer          default(0)
#  charitable_noncash     :integer          default(0)
#  claimed_as_dep         :integer
#  contact_preference     :integer          default("unfilled"), not null
#  current_step           :string
#  email_address          :citext
#  phone_number           :string
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
  accepts_nested_attributes_for :dependents, update_only: true

  encrypts :bank_account_number, :bank_routing_number, :raw_direct_file_data

  enum bank_account_type: { unfilled: 0, checking: 1, savings: 2, unspecified: 3 }, _prefix: :bank_account_type

  def tax_calculator(include_source: false)
    Efile::Az::Az140.new(
      year: 2022,
      filing_status: filing_status.to_sym,
      claimed_as_dependent: claimed_as_dep_yes?,
      intake: self,
      dependent_count: dependents.length,
      direct_file_data: direct_file_data,
      include_source: include_source,
    )
  end

  def federal_dependent_count_under_17
    # TODO
    1
  end

  def federal_dependent_count_over_17
    # TODO
    0
  end

  def qualifying_parents_and_grandparents
    # TODO
    0
  end

  def sentenced_for_60_days
    # TODO
  end
end
