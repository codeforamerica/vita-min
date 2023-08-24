class StateFileQuestionNavigation
  include ControllerNavigation

  FLOW = [
    StateFile::Questions::AllInfoController,
    StateFile::Questions::SubmitReturnController
  ].freeze
end
