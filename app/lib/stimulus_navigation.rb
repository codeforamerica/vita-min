class StimulusNavigation
  FLOW = [
    Stimulus::FiledRecentlyController,
    Stimulus::NeedToCorrectController,
    Stimulus::FiledPriorYearsController,
    Stimulus::NeedToFileController,
    Stimulus::FileForStimulusController,
    Stimulus::VisitStimulusFaqController
  ].freeze

  include ControllerNavigation
end
