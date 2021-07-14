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
    Ctc::Questions::PlaceholderQuestionController,

    # RRC
    Ctc::Questions::StimulusPaymentsController,
    Ctc::Questions::StimulusOneController,
    Ctc::Questions::StimulusOneReceivedController,
    Ctc::Questions::StimulusTwoController,
    Ctc::Questions::StimulusTwoReceivedController,
    Ctc::Questions::PlaceholderQuestionController,

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