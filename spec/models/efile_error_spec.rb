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
  it 'returns data review as the default controller' do
    expect(EfileError.default_controller("az")).to eq StateFile::Questions::AzReviewController
  end

  it 'converts controllers to paths' do
    path = EfileError.controller_to_path(StateFile::Questions::AzReviewController)
    expect(path).to eq "az-review"
  end

  it 'converts paths to controllers' do
    controller = EfileError.path_to_controller("az-review")
    expect(controller).to eq StateFile::Questions::AzReviewController
  end

  it 'returns the expected array of paths' do
    expect(EfileError.paths).to eq [
      "az-charitable-contributions",
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
      "data-transfer-offboarding",
      "declined-terms-and-conditions",
      "eligibility-offboarding",
      "eligible",
      "email-address",
      "esign-declaration",
      "federal-info",
      "id-donations",
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
      "md-had-health-insurance",
      "md-permanent-address",
      "md-review",
      "md-tax-refund",
      "md-two-income-subtractions",
      "nc-county",
      "nc-eligibility",
      "nc-review",
      "nc-sales-use-tax",
      "nc-subtractions",
      "nc-tax-refund",
      "nc-taxes-owed",
      "nc-veteran-status",
      "nj-college-dependents-exemption",
      "nj-county",
      "nj-disabled-exemption",
      "nj-eitc-qualifying-child",
      "nj-eligibility-health-insurance",
      "nj-estimated-tax-payments",
      "nj-gubernatorial-elections",
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
      "notification-preferences",
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
      "post-data-transfer",
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
