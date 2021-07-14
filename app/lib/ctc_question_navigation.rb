class CtcQuestionNavigation
  include ControllerNavigation

  FLOW = [
    Ctc::Questions::OverviewController,
    Ctc::Questions::PersonalInfoController,
    Ctc::Questions::ContactPreferenceController,
    Ctc::Questions::CellPhoneNumberController,
    Ctc::Questions::EmailAddressController,
    Ctc::Questions::ReturningClientController,
    Ctc::Questions::EmailVerificationController,
    Ctc::Questions::PhoneVerificationController,
    Ctc::Questions::ConsentController,
    Ctc::Questions::PlaceholderQuestionController,

    # RRC
    Ctc::Questions::StimulusPaymentsController,

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