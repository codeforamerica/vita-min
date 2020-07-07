class StimulusNavigation
  FLOW = [
    Stimulus::FiledRecentlyController,
    Stimulus::NeedToCorrectController,
    Stimulus::FiledPriorYearsController,
    Stimulus::NeedToFileController,
    Stimulus::FileForStimulusController,
    Stimulus::VisitStimulusFaqController,
    Stimulus::FilingMightHelpController
  ].freeze

  include ControllerNavigation
end
