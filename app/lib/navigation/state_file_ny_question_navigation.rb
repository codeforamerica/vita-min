module Navigation
  class StateFileNyQuestionNavigation
    include ControllerNavigation

    FLOW = [
      StateFile::Questions::FederalInfoController,
      StateFile::Questions::SubmitReturnController
    ].freeze
  end
end
