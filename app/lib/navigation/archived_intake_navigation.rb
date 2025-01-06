module Navigation
  class ArchivedIntakeNavigation < Navigation::StateFileBaseQuestionNavigation
    include ControllerNavigation

    SECTIONS = [
      Navigation::NavigationSection.new("state_file.navigation.section_1", [
        Navigation::NavigationStep.new(StateFile::Questions::EmailAddressValidationController),
        Navigation::NavigationStep.new(StateFile::Questions::ArchivedIntakeVerificationCodeController)
      ]),
    ].freeze
    FLOW = SECTIONS.map(&:controllers).flatten.freeze
  end
end
