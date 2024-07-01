require "rails_helper"

RSpec.describe Navigation::StateFileAzQuestionNavigation do
  describe "Flow" do
    it "Flow has not changed" do
      expect(Navigation::StateFileAzQuestionNavigation::FLOW).to eq([
        StateFile::Questions::LandingPageController, # creates state_intake (StartIntakeConcern)
        StateFile::Questions::EligibilityResidenceController,
        StateFile::Questions::AzEligibilityOutOfStateIncomeController,
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
        StateFile::Questions::AzSeniorDependentsController,
        StateFile::Questions::AzPriorLastNamesController,
        StateFile::Questions::W2Controller,
        StateFile::Questions::UnemploymentController,
        StateFile::Questions::AzStateCreditsController,
        StateFile::Questions::AzCharitableContributionsController,
        StateFile::Questions::AzExciseCreditController,
        StateFile::Questions::AzPrimaryStateIdController,
        StateFile::Questions::AzSpouseStateIdController,
        StateFile::Questions::AzReviewController,
        StateFile::Questions::TaxesOwedController,
        StateFile::Questions::TaxRefundController,
        StateFile::Questions::EsignDeclarationController, # creates EfileSubmission and transitions to preparing
        StateFile::Questions::SubmissionConfirmationController,
        StateFile::Questions::ReturnStatusController,
      ])
    end
  end

  context "get_section" do
    it "gets the correct section" do
      section = Navigation::StateFileAzQuestionNavigation.get_section(StateFile::Questions::AzReviewController)
      expect(section.title).to eq "state_file.navigation.section_5"
    end
  end

  context "number_of_steps" do
    it "returns the correct number of steps" do
      expect(Navigation::StateFileAzQuestionNavigation.number_of_steps).to eq 6
    end
  end

  context "get_progress" do
    it "returns the correct progress" do
      progress = Navigation::StateFileAzQuestionNavigation.get_progress(StateFile::Questions::FederalInfoController)
      expect(progress).to eq({
         title: "Section 5: Complete your state tax return",
         step_number: 4,
         number_of_steps: 6
      })
    end
  end
end