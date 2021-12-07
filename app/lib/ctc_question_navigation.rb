class CtcQuestionNavigation
  include ControllerNavigation

  FLOW = [
    # Basic info
    Ctc::Questions::OverviewController,
    Ctc::Questions::IncomeController, # At this point we create the intake, client, and tax return
    Ctc::Questions::FileFullReturnController,

    # Eligibility
    Ctc::Questions::AlreadyFiledController,
    Ctc::Questions::FiledPriorTaxYearController,
    Ctc::Questions::LifeSituations2019Controller,
    Ctc::Questions::HomeController,
    Ctc::Questions::LifeSituations2020Controller,

    # Consent/Contact
    Ctc::Questions::LegalConsentController,
    Ctc::Questions::PriorYearAgiController,
    Ctc::Questions::ContactPreferenceController,
    Ctc::Questions::CellPhoneNumberController,
    Ctc::Questions::EmailAddressController,
    Ctc::Questions::EmailVerificationController,  # At this verification point we sign in the client
    Ctc::Questions::PhoneVerificationController,  # Same sign in behavior as previous controller, but verified through SMS instead of email

    # Filing Status
    Ctc::Questions::FilingStatusController, # This and all later controllers require the client to be signed in
    Ctc::Questions::SpouseInfoController,
    Ctc::Questions::SpouseFiledPriorTaxYearController,
    Ctc::Questions::SpousePriorYearAgiController,
    Ctc::Questions::SpouseReviewController,

    # Dependents
    Ctc::Questions::Dependents::HadDependentsController,
    Ctc::Questions::Dependents::InfoController,
    Ctc::Questions::Dependents::ChildDisqualifiersController,
    Ctc::Questions::Dependents::ChildLivedWithYouController,
    Ctc::Questions::Dependents::ChildResidenceExceptionsController,
    Ctc::Questions::Dependents::ChildCanBeClaimedByOtherController,
    Ctc::Questions::Dependents::ClaimChildAnywayController,
    Ctc::Questions::Dependents::QualifyingRelativeController,
    Ctc::Questions::Dependents::DoesNotQualifyCtcController,
    Ctc::Questions::Dependents::ConfirmDependentsController,

    # RRC
    Ctc::Questions::StimulusPaymentsController,
    Ctc::Questions::StimulusOneController,
    Ctc::Questions::StimulusOneReceivedController,
    Ctc::Questions::StimulusTwoController,
    Ctc::Questions::StimulusTwoReceivedController,
    Ctc::Questions::StimulusReceivedController,
    Ctc::Questions::StimulusOwedController,

    # Bank and mailing info
    Ctc::Questions::RefundPaymentController,

    # DEPRECATED - remove soon
    Ctc::Questions::DirectDepositController,
    Ctc::Questions::RoutingNumberController,
    Ctc::Questions::AccountNumberController,

    Ctc::Questions::BankAccountController,
    Ctc::Questions::ConfirmBankAccountController,
    Ctc::Questions::MailingAddressController,
    Ctc::Questions::ConfirmMailingAddressController,

    # Review
    Ctc::Questions::IpPinController,
    Ctc::Questions::IpPinEntryController,
    Ctc::Questions::ConfirmInformationController,
    Ctc::Questions::ConfirmPaymentController,
    Ctc::Questions::ConfirmLegalController, # sets completed_at, after which a client will no longer be able to make changes in the questions flow.
  ].freeze
end
