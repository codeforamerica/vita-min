class QuestionNavigation
  include ControllerNavigation

  FLOW = [
      Questions::WelcomeController,
      Questions::TriageTaxNeedsController,
      Questions::TriageStimulusCheckController,
      Questions::TriageEligibilityController, # VITA triage_eligibility checks\
      Questions::TriageBacktaxesController,
      Questions::TriageLookbackController,
      Questions::TriageSimpleTaxController,
      Questions::TriagePrepareSoloController,
      Questions::TriageArpController,

      ## Main flow
      Questions::FileWithHelpController,
      Questions::BacktaxesController, # creates Intake record
      Questions::EnvironmentWarningController,
      Questions::StartWithCurrentYearController,

      # Overview
      Questions::OverviewController,

      # Contact information
      Questions::PersonalInfoController,
      Questions::AtCapacityController,
      Questions::ChatWithUsController,
      Questions::PhoneNumberController,
      Questions::EmailAddressController,
      Questions::ReturningClientController, # possible off-boarding from flow
      Questions::NotificationPreferenceController,

      # Consent
      Questions::ConsentController, # Authenticates the client
                                    # Advances statuses to "In Progress"
                                    # generate a 14446 signed by the primary
                                    # generate a "Preliminary" 13614-C signed by the primary
      Questions::OptionalConsentController, # This and all later controllers require a client to be signed in.

      # Primary filer personal information
      Questions::LifeSituationsController,
      Questions::StimulusPaymentsController,
      Questions::IssuedIdentityPinController,

      # Marital Status
      Questions::EverMarriedController,
      Questions::MarriedController,
      Questions::LivedWithSpouseController,
      Questions::SeparatedController,
      Questions::SeparatedYearController,
      Questions::DivorcedController,
      Questions::DivorcedYearController,
      Questions::WidowedController,
      Questions::WidowedYearController,

      # Filing status
      Questions::FilingJointController,

      # Alimony
      Questions::ReceivedAlimonyController,
      Questions::PaidAlimonyController,

      # Spouse email
      Questions::SpouseEmailAddressController,

      # Spouse consent
      Questions::SpouseConsentController, # generate and replace the 14446 signed by the primary
                                          # generate and replace "Preliminary" 13614-C signed by the primary and spouse

      # Spouse personal information
      Questions::SpouseLifeSituationsController,
      Questions::SpouseIssuedIdentityPinController,

      # Dependents
      Questions::HadDependentsController,

      # DependentsController (if they had dependents)

      # Dependent related questions
      Questions::DependentCareController,
      Questions::AdoptedChildController,

      # Student questions
      Questions::StudentController,
      Questions::StudentLoanInterestController,

      # Income from working
      Questions::JobCountController,
      Questions::OtherStatesController,

      # Work Situations
      Questions::WorkSituationsController,

      # Income from benefits
      Questions::DisabilityIncomeController,

      # Investment interest
      Questions::InterestIncomeController,

      # Investment sale income or loss
      Questions::SoldAssetsController,
      Questions::AssetSaleIncomeController,
      Questions::AssetSaleLossController,

      # Retirement income/contributions
      Questions::SocialSecurityOrRetirementController,
      Questions::SocialSecurityIncomeController,
      Questions::RetirementIncomeController,
      Questions::RetirementContributionsController,

      # Other income
      Questions::OtherIncomeController,
      Questions::OtherIncomeTypesController,

      # Health insurance
      Questions::HealthInsuranceController,
      Questions::HsaController,

      # Itemizing
      Questions::MedicalExpensesController,
      Questions::CharitableContributionsController,
      Questions::GamblingIncomeController,
      Questions::SchoolSuppliesController,
      Questions::LocalTaxController,
      Questions::LocalTaxRefundController,

      # Related to home ownership
      Questions::SoldHomeController,
      Questions::MortgageInterestController,
      Questions::HomebuyerCreditController,

      # Miscellaneous
      Questions::DisasterLossController,
      Questions::DebtForgivenController,
      Questions::IrsLetterController,
      Questions::TaxCreditDisallowedController,
      Questions::EstimatedTaxPaymentsController,
      Questions::SelfEmploymentLossController,
      Questions::EnergyEfficientPurchasesController,

      # Additional Information
      Questions::AdditionalInfoController, # sets 'completed_yes_no_questions_at'
                                           # generate and replace the "Preliminary" 13614-C signed by the primary and spouse with yes/no questions filled out

      # Documents --> See DocumentNavigation
      Questions::OverviewDocumentsController,

      # Interview time preferences
      Questions::InterviewSchedulingController,

      # Payment info
      Questions::RefundPaymentController,
      Questions::SavingsOptionsController,
      Questions::BalancePaymentController,
      Questions::BankDetailsController,
      Questions::MailingAddressController,

      # Optional Demographic Questions
      Questions::DemographicQuestionsController,
      Questions::DemographicEnglishConversationController,
      Questions::DemographicEnglishReadingController,
      Questions::DemographicDisabilityController,
      Questions::DemographicVeteranController,
      Questions::DemographicPrimaryRaceController,
      Questions::DemographicSpouseRaceController,
      Questions::DemographicPrimaryEthnicityController,
      Questions::DemographicSpouseEthnicityController,

      # Additional Information
      Questions::FinalInfoController, # sets 'completed_at' & creates Original 13614-C
                                      # replace "Preliminary" with "Original" 13614-C completely filled out
      Questions::SuccessfullySubmittedController,
      Questions::FeedbackController,
  ].freeze

  # Provides a backfill to determine the current_step value for clients who started intake previous to the addition of
  # determining current_step during the intake flow
  # TODO: Remove after 2021 tax season closes.
  def self.determine_current_step(intake)
    return if intake.completed_at?
    return Questions::ConsentController.to_path_helper unless intake.primary_consented_to_service_at?

    # If yes/no questions have been completed and we definitely still need certain documents, send
    # them to the upload docs page.
    if intake.completed_yes_no_questions_at? && intake.document_types_definitely_needed.present?
      return Documents::OverviewController.to_path_helper
    end

    first_relevant_question_index = intake.completed_yes_no_questions_at? ? FLOW.index(Questions::OverviewDocumentsController) : FLOW.index(Questions::OptionalConsentController)
    # If yes/no questions completed + docs uploaded, start at InterviewScheduling. Else, start after OptionalConsent
    relevant_questions = FLOW.slice(first_relevant_question_index+1..)
    relevant_questions.each do |question|
      # Skip if not relevant to this intake
      next unless question.show?(intake)
      next if later_questions_2020.include?(question)

      # Return if unfilled
      answer = intake.send(question.form_class.attribute_names.first)
      return question.to_path_helper.to_s if ["unfilled", nil].include? answer
    end
  end

  # Questions added later in the season in 2020 -- we don't need to send returning clients back to answer new questions,
  # per product.
  def self.later_questions_2020
    [Questions::StimulusPaymentsController]
  end
end
