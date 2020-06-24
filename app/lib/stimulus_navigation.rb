class StimulusNavigation
  FLOW = [
    Stimulus::FiledRecentlyController,
    Stimulus::NeedToCorrectController
  ].freeze

  include ControllerNavigation
end
