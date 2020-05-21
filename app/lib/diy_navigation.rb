class DiyNavigation
  FLOW = [
    Diy::FileYourselfController,
    Diy::PersonalInfoController,
    Diy::EmailAddressController,
    Diy::CheckEmailController,
  ].freeze

  include ControllerNavigation
end
