# == Schema Information
#
# Table name: state_file_az_intakes
#
#  id                        :bigint           not null, primary key
#  armed_forces_member       :integer          default("unfilled"), not null
#  armed_forces_wages        :integer
#  bank_account_number       :string
#  bank_account_type         :integer
#  bank_routing_number       :string
#  charitable_cash           :integer          default(0)
#  charitable_noncash        :integer          default(0)
#  claimed_as_dep            :integer          default("unfilled")
#  contact_preference        :integer          default("unfilled"), not null
#  current_step              :string
#  email_address             :citext
#  email_address_verified_at :datetime
#  has_prior_last_names      :integer          default("unfilled"), not null
#  phone_number              :string
#  phone_number_verified_at  :datetime
#  primary_first_name        :string
#  primary_last_name         :string
#  primary_middle_initial    :string
#  prior_last_names          :string
#  raw_direct_file_data      :text
#  referrer                  :string
#  source                    :string
#  spouse_first_name         :string
#  spouse_last_name          :string
#  spouse_middle_initial     :string
#  tribal_member             :integer          default("unfilled"), not null
#  tribal_wages              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visitor_id                :string
#
class StateFileAzIntake < StateFileBaseIntake
  encrypts :bank_account_number, :bank_routing_number, :raw_direct_file_data

  enum bank_account_type: { unfilled: 0, checking: 1, savings: 2, unspecified: 3 }, _prefix: :bank_account_type
  enum has_prior_last_names: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_prior_last_names
  enum tribal_member: { unfilled: 0, yes: 1, no: 2 }, _prefix: :tribal_member
  enum armed_forces_member: { unfilled: 0, yes: 1, no: 2 }, _prefix: :armed_forces_member

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
    dependents.select(&:ask_senior_questions?).length
  end

  def sentenced_for_60_days
    # TODO
  end

  def ask_months_in_home?
    true
  end

  def ask_primary_dob?
    false
  end

  def ask_spouse_dob?
    false
  end
end
