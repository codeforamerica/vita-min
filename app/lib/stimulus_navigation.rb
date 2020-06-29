class StimulusNavigation
  FLOW = [
    Stimulus::FiledRecentlyController,
    Stimulus::NeedToCorrectController,
    Stimulus::FiledPriorYearsController,
    Stimulus::VisitStimulusFaqController
  ].freeze

  include ControllerNavigation
end
