module Navigation
  class DiyNavigation
    include ControllerNavigation

    FLOW = [
      Diy::QualificationsController,
      Diy::FileYourselfController,
      Diy::DiyNotificationPreferenceController,
      Diy::DiyCellPhoneNumberController,
      #Diy::DiyPhoneVerificationController,
      #Diy::DiyEmailAddressController,
      #Diy::DiyEmailAddressVerificationController,
      Diy::ContinueToFsaController
    ].freeze
  end
end
