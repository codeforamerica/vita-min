class DiyNavigation
  FLOW = [
    Diy::FileYourselfController,
    Diy::PersonalInfoController,
  ].freeze

  include ControllerNavigation
end
