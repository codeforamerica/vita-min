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
    controller = EfileError.path_to_controller("w2")
    expect(controller).to eq StateFile::Questions::W2Controller
  end

  it 'returns the expected array of paths' do
    expect(EfileError.paths).to eq [
      "az-charitable-contributions",
      "az-excise-credit",
      "az-primary-state-id",
      "az-prior-last-names",
      "az-review",
      "az-senior-dependents",
      "az-spouse-state-id",
      "az-state-credits",
      "canceled-data-transfer",
      "code-verified",
      "contact-preference",
      "data-review",
      "data-transfer-offboarding",
      "declined-terms-and-conditions",
      "eligibility-offboarding",
      "eligibility-out-of-state-income",
      "eligibility-residence",
      "eligible",
      "email-sign-up",
      "esign-declaration",
      "federal-info",
      "initiate-data-transfer",
      "landing-page",
      "name-dob",
      "ny-county",
      "ny-eligibility-college-savings-withdrawal",
      "ny-permanent-address",
      "ny-primary-state-id",
      "ny-review",
      "ny-sales-use-tax",
      "ny-school-district",
      "ny-spouse-state-id",
      "ny-third-party-designee",
      "nyc-residency",
      "phone-number-sign-up",
      "return-status",
      "submission-confirmation",
      "tax-refund",
      "taxes-owed",
      "terms-and-conditions",
      "unemployment",
      "w2",
      "waiting-to-load-data"
    ]
  end
end
