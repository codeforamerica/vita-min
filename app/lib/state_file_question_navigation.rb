class StateFileQuestionNavigation
  include ControllerNavigation

  FLOW = [
    StateFile::Questions::AllInfoController,
  ].freeze
end
