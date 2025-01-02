module Navigation
  class ArchivedIntakeNavigation < Navigation::StateFileBaseQuestionNavigation
    include ControllerNavigation

    SECTIONS = [
      Navigation::NavigationSection.new("state_file.navigation.section_1", [
        Navigation::NavigationStep.new(StateFile::Questions::ArchivedIntakeEmailAddressController),
        Navigation::NavigationStep.new(StateFile::Questions::ValidateIdentificationNumberController),
      ]),
    ].freeze
    FLOW = SECTIONS.map(&:controllers).flatten.freeze
  end
end
