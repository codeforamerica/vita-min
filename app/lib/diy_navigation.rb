class DiyNavigation
  FLOW = [
    Diy::FileYourselfController,
    Diy::OverviewController,
    Diy::LocationController,
    Diy::EmailController,
  ].freeze

  include ControllerNavigation
end
