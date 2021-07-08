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

    # payments information
    Ctc::Questions::RefundPaymentController,
    Ctc::Questions::DirectDepositController,
    Ctc::Questions::MailingAddressController,
  ].freeze
end