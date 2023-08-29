module Navigation
  class StateFileQuestionNavigation
    include ControllerNavigation

    FLOW = [
      StateFile::Questions::FederalInfoController,
      StateFile::Questions::SubmitReturnController
    ].freeze
  end
end
