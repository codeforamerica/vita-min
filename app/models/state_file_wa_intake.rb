# == Schema Information
#
# Table name: state_file_wa_intakes
#
#  id                                :bigint           not null, primary key
#  account_type                      :integer          default("unfilled"), not null
#  city                              :string
#  consented_to_terms_and_conditions :integer          default("unfilled"), not null
#  contact_preference                :integer          default("unfilled"), not null
#  current_sign_in_at                :datetime
#  current_sign_in_ip                :inet
#  current_step                      :string
#  eligibility_lived_in_state        :integer          default("unfilled"), not null
#  eligibility_out_of_state_income   :integer          default("unfilled"), not null
#  email_address                     :citext
#  email_address_verified_at         :datetime
#  failed_attempts                   :integer          default(0), not null
#  filing_status                     :integer
#  last_sign_in_at                   :datetime
#  last_sign_in_ip                   :inet
#  locale                            :string           default("en")
#  locked_at                         :datetime
#  payment_or_deposit_type           :integer          default("unfilled"), not null
#  phone_number                      :string
#  phone_number_verified_at          :datetime
#  primary_birth_date                :date
#  primary_esigned                   :integer          default("unfilled"), not null
#  primary_first_name                :string
#  primary_last_name                 :string
#  raw_direct_file_data              :text
#  referrer                          :string
#  sign_in_count                     :integer          default(0), not null
#  source                            :string
#  spouse_esigned                    :integer          default("unfilled"), not null
#  ssn                               :string
#  street_address                    :string
#  tax_return_year                   :integer
#  zip_code                          :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  visitor_id                        :string
#
class StateFileWaIntake < StateFileBaseIntake
  def tax_calculator(include_source: false)
    Efile::Wa::Wa1000.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: self,
      include_source: include_source
    )
  end
end
