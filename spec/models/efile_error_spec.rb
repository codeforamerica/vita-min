# == Schema Information
#
# Table name: efile_errors
#
#  id              :bigint           not null, primary key
#  auto_cancel     :boolean          default(FALSE)
#  auto_wait       :boolean          default(FALSE)
#  category        :string
#  code            :string
#  correction_path :string
#  expose          :boolean          default(FALSE)
#  message         :text
#  service_type    :integer          default("unfilled"), not null
#  severity        :string
#  source          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

describe 'EfileError' do
  it 'returns name dob as the default controller' do
    expect(EfileError.default_controller).to eq StateFile::Questions::NameDobController
  end

  it 'converts controllers to paths' do
    path = EfileError.controller_to_path(StateFile::Questions::NameDobController)
    expect(path).to eq "name-dob"
  end

  it 'converts paths to controllers' do
    controller = EfileError.path_to_controller("name-dob")
    expect(controller).to eq StateFile::Questions::NameDobController
  end

  it 'returns the expected array of paths' do
    expect(EfileError.paths).to eq [
      "az-charitable-contributions",
      "az-eligibility-out-of-state-income",
      "az-eligibility-residence",
      "az-excise-credit",
      "az-prior-last-names",
      "az-public-school-contributions",
      'az-qualifying-organization-contributions',
      "az-review",
      "az-senior-dependents",
      "az-subtractions",
      "canceled-data-transfer",
      "code-verified",
      "contact-preference",
      "data-review",
      "data-transfer-offboarding",
      "declined-terms-and-conditions",
      "eligibility-offboarding",
      "eligible",
      "email-address",
      "esign-declaration",
      "federal-info",
      "id-eligibility-residence",
      "id-grocery-credit",
      "id-grocery-credit-review",
      "id-health-insurance-premium",
      "id-permanent-building-fund",
      "id-review",
      "id-sales-use-tax",
      "income-review",
      "initiate-data-transfer",
      "md-county",
      "md-eligibility-filing-status",
      "md-permanent-address",
      "md-review",
      "md-tax-refund",
      "name-dob",
      "nc-county",
      "nc-eligibility-out-of-state-income",
      "nc-eligibility-residence",
      "nc-review",
      "nc-sales-use-tax",
      "nc-subtractions",
      "nc-veteran-status",
      "nj-county",
      "nj-disabled-exemption",
      "nj-estimated-tax-payments",
      "nj-homeowner-eligibility",
      "nj-homeowner-property-tax",
      "nj-household-rent-own",
      "nj-ineligible-property-tax",
      "nj-medical-expenses",
      "nj-municipality",
      "nj-review",
      "nj-sales-use-tax",
      "nj-tenant-eligibility",
      "nj-tenant-rent-paid",
      "nj-unsupported-property-tax",
      "nj-veterans-exemption",
      "ny-county",
      "ny-eligibility-college-savings-withdrawal",
      "ny-eligibility-out-of-state-income",
      "ny-eligibility-residence",
      "ny-permanent-address",
      "ny-primary-state-id",
      "ny-review",
      "ny-sales-use-tax",
      "ny-school-district",
      "ny-spouse-state-id",
      "ny-third-party-designee",
      "nyc-residency",
      "phone-number",
      "primary-state-id",
      "return-status",
      "spouse-state-id",
      "submission-confirmation",
      "tax-refund",
      "taxes-owed",
      "terms-and-conditions",
      "unemployment",
      "verification-code",
      "waiting-to-load-data"
    ]
  end
end
