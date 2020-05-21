class DiyNavigation
  FLOW = [
    Diy::FileYourselfController,
    Diy::PersonalInfoController,
    Diy::EmailAddressController,
  ].freeze

  include ControllerNavigation
end
