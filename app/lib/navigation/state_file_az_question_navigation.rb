module Navigation
  class StateFileAzQuestionNavigation
    include ControllerNavigation

    FLOW = [
      StateFile::Questions::FederalInfoController,
      StateFile::Questions::SubmitReturnController
    ].freeze
  end
end
