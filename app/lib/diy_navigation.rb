class DiyNavigation
  FLOW = [
    Diy::FileYourselfController,
    Diy::OverviewController,
    Diy::LocationController
  ].freeze

  include ControllerNavigation
end
