module Navigation
  class CompletedTaxReturnNavigation < Navigation::StateFileBaseQuestionNavigation
    include ControllerNavigation

    SECTIONS = [
      Navigation::NavigationSection.new("state_file.navigation.section_1", [
        Navigation::NavigationStep.new(StateFile::Questions::CompletedReturnEmailAddressController),
      ]),
    ].freeze
    FLOW = SECTIONS.map(&:controllers).flatten.freeze
  end
end
