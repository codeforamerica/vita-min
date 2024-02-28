require "rails_helper"

RSpec.describe Navigation::StateFileNyQuestionNavigation do

  describe "Flow" do
    it "Flow has not changed" do
      expect(Navigation::StateFileNyQuestionNavigation::FLOW).to eq([
        StateFile::Questions::LandingPageController, # creates state_intake (StartIntakeConcern)
        StateFile::Questions::EligibilityResidenceController,
        StateFile::Questions::EligibilityOutOfStateIncomeController,
        StateFile::Questions::NyEligibilityCollegeSavingsWithdrawalController,
        StateFile::Questions::EligibilityOffboardingController,
        StateFile::Questions::EligibleController,
        StateFile::Questions::ContactPreferenceController,
        StateFile::Questions::PhoneNumberController,
        StateFile::Questions::EmailAddressController,
        StateFile::Questions::VerificationCodeController,
        StateFile::Questions::CodeVerifiedController,
        StateFile::Questions::TermsAndConditionsController,
        StateFile::Questions::DeclinedTermsAndConditionsController,
        StateFile::Questions::InitiateDataTransferController,
        StateFile::Questions::CanceledDataTransferController, # show? false
        StateFile::Questions::WaitingToLoadDataController,
        StateFile::Questions::DataReviewController,
        StateFile::Questions::FederalInfoController,
        StateFile::Questions::DataTransferOffboardingController,
        StateFile::Questions::NameDobController,
        StateFile::Questions::NycResidencyController,
        StateFile::Questions::NyPermanentAddressController,
        StateFile::Questions::NyCountyController,
        StateFile::Questions::NySchoolDistrictController,
        StateFile::Questions::NySalesUseTaxController,
        StateFile::Questions::NyPrimaryStateIdController,
        StateFile::Questions::NySpouseStateIdController,
        StateFile::Questions::UnemploymentController,
        StateFile::Questions::NyReviewController,
        StateFile::Questions::TaxesOwedController,
        StateFile::Questions::TaxRefundController,
        StateFile::Questions::EsignDeclarationController, # creates EfileSubmission and transitions to preparing
        StateFile::Questions::SubmissionConfirmationController,
        StateFile::Questions::ReturnStatusController,
      ])
    end
  end
end