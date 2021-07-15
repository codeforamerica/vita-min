class CtcQuestionNavigation
  include ControllerNavigation

  FLOW = [
    # Basic info
    Ctc::Questions::OverviewController,
    Ctc::Questions::IncomeController,
    Ctc::Questions::ConsentController,
    Ctc::Questions::ContactPreferenceController,
    Ctc::Questions::CellPhoneNumberController,
    Ctc::Questions::EmailAddressController,
    Ctc::Questions::ReturningClientController,
    Ctc::Questions::EmailVerificationController,
    Ctc::Questions::PhoneVerificationController,
    Ctc::Questions::Filed2020Controller,
    Ctc::Questions::Filed2020YesController,
    Ctc::Questions::Filed2019Controller,
    Ctc::Questions::LifeSituations2019Controller,
    Ctc::Questions::HomeController,

    # Filing Status
    Ctc::Questions::FilingStatusController,
    Ctc::Questions::SpouseInfoController,

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