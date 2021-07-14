class CtcQuestionNavigation
  include ControllerNavigation

  FLOW = [
    Ctc::Questions::OverviewController,
    Ctc::Questions::PersonalInfoController,
    Ctc::Questions::ContactPreferenceController,
    Ctc::Questions::CellPhoneNumberController,
    Ctc::Questions::EmailAddressController,
    Ctc::Questions::VerificationController,
    Ctc::Questions::ConsentController,
    Ctc::Questions::Filed2020Controller,
    Ctc::Questions::Filed2020YesController,
    Ctc::Questions::Filed2019Controller,
    Ctc::Questions::LifeSituations2019Controller,
    Ctc::Questions::PlaceholderQuestionController,

    # RRC
    Ctc::Questions::StimulusPaymentsController,
    Ctc::Questions::StimulusOneController,
    Ctc::Questions::StimulusOneReceivedController,
    Ctc::Questions::StimulusTwoController, # StimulusTwoController and StimulusTwoReceivedController will conditionally redirect to StimulusReceivedController or StimulusOwedController
    Ctc::Questions::StimulusTwoReceivedController,
    Ctc::Questions::StimulusReceivedController, # StimulusReceivedController has a link in the view to RefundPaymentController (does not rely on next_path)
    Ctc::Questions::StimulusOwedController,

    # payments information
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