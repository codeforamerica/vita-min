class CtcQuestionNavigation
  include ControllerNavigation

  FLOW = [
    # Basic info
    Ctc::Questions::OverviewController,
    Ctc::Questions::IncomeController,
    Ctc::Questions::ConsentController,            # At this point we create the intake, client, and tax return
    Ctc::Questions::ContactPreferenceController,
    Ctc::Questions::CellPhoneNumberController,
    Ctc::Questions::EmailAddressController,
    Ctc::Questions::ReturningClientController,
    Ctc::Questions::EmailVerificationController,  # At this verification point we sign in the client
    Ctc::Questions::PhoneVerificationController,  # Same sign in behavior as previous controller, but verified through SMS instead of email

    # Life Situations
    Ctc::Questions::Filed2020Controller, # This and all later controllers require the client to be signed in
    Ctc::Questions::Filed2020YesController,
    Ctc::Questions::Filed2019Controller,
    Ctc::Questions::LifeSituations2019Controller,
    Ctc::Questions::HomeController,
    Ctc::Questions::LifeSituations2020Controller,

    # Filing Status
    Ctc::Questions::FilingStatusController,
    Ctc::Questions::SpouseInfoController,
    Ctc::Questions::SpouseReviewController,

    # Dependents
    Ctc::Questions::Dependents::HadDependentsController,
    Ctc::Questions::Dependents::NoDependentsController,
    Ctc::Questions::Dependents::InfoController,
    Ctc::Questions::Dependents::TinController,
    Ctc::Questions::Dependents::ConfirmDependentsController,

    # RRC
    Ctc::Questions::StimulusPaymentsController,
    Ctc::Questions::StimulusOneController,
    Ctc::Questions::StimulusOneReceivedController,
    Ctc::Questions::StimulusTwoController, # StimulusTwoController and StimulusTwoReceivedController will conditionally redirect to StimulusReceivedController or StimulusOwedController
    Ctc::Questions::StimulusTwoReceivedController,
    Ctc::Questions::StimulusReceivedController, # StimulusReceivedController has a link in the view to RefundPaymentController (does not rely on next_path)
    Ctc::Questions::StimulusOwedController,

    # Bank and mailing info
    Ctc::Questions::RefundPaymentController,
    Ctc::Questions::DirectDepositController,
    Ctc::Questions::RoutingNumberController,
    Ctc::Questions::AccountNumberController,
    Ctc::Questions::ConfirmBankAccountController,
    Ctc::Questions::MailingAddressController,
    Ctc::Questions::ConfirmMailingAddressController,
    Ctc::Questions::IpPinController,
  ].freeze
end
