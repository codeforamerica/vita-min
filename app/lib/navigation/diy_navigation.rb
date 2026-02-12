module Navigation
  class DiyNavigation
    include ControllerNavigation

    FLOW = [
      Diy::QualificationsController,
      Diy::FileYourselfController,
      Diy::DiyNotificationPreferenceController,
      #Diy::DiyEmailAddressController,
      Diy::ContinueToFsaController
    ].freeze
  end
end
