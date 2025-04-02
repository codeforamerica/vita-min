require "rails_helper"

RSpec.describe Navigation::StateFileAzQuestionNavigation do
  describe "Flow" do
    it "Flow has not changed" do
      expected_flow = [
        StateFile::Questions::EligibleController,
        StateFile::Questions::ContactPreferenceController,
        StateFile::Questions::PhoneNumberController,
        StateFile::Questions::EmailAddressController,
        StateFile::Questions::VerificationCodeController,
        StateFile::Questions::CodeVerifiedController,
        StateFile::Questions::NotificationPreferencesController,
        StateFile::Questions::SmsTermsController,
        StateFile::Questions::TermsAndConditionsController,
        StateFile::Questions::DeclinedTermsAndConditionsController,
        StateFile::Questions::InitiateDataTransferController,
        StateFile::Questions::CanceledDataTransferController, # show? false
        StateFile::Questions::WaitingToLoadDataController,
        StateFile::Questions::PostDataTransferController,
        StateFile::Questions::FederalInfoController,
        StateFile::Questions::DataTransferOffboardingController,
        StateFile::Questions::AzSeniorDependentsController,
        StateFile::Questions::AzPriorLastNamesController,
        StateFile::Questions::IncomeReviewController,
        StateFile::Questions::UnemploymentController,
        StateFile::Questions::AzRetirementIncomeSubtractionController,
        StateFile::Questions::AzPublicSchoolContributionsController,
        StateFile::Questions::AzCharitableContributionsController,
        StateFile::Questions::AzQualifyingOrganizationContributionsController,
        StateFile::Questions::AzSubtractionsController,
        StateFile::Questions::AzExciseCreditController,
        StateFile::Questions::ExtensionPaymentsController,
        StateFile::Questions::PrimaryStateIdController,
        StateFile::Questions::SpouseStateIdController,
        StateFile::Questions::AzReviewController,
        StateFile::Questions::TaxesOwedController,
        StateFile::Questions::TaxRefundController,
        StateFile::Questions::EsignDeclarationController, # creates EfileSubmission and transitions to preparing
        StateFile::Questions::SubmissionConfirmationController,
        StateFile::Questions::ReturnStatusController,
      ]
      expect(Navigation::StateFileAzQuestionNavigation::FLOW).to eq(expected_flow)
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
                               title: "Complete your state tax return",
                               step_number: 4,
                               number_of_steps: 6
                             })
    end
  end
end
