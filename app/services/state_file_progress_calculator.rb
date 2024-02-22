class StateFileProgressCalculator

  SECTIONS = [
    {
      title: "Section 1: Can you use this tool",
      step: StateFile::Questions::EligibilityResidenceController
    },
    {
      title: "Section 2: Create account",
      step: StateFile::Questions::ContactPreferenceController
    },
    {
      title: "Section 3: Terms and conditions",
      step: StateFile::Questions::TermsAndConditionsController
    },
    {
      title: "Section 4: Transfer your data",
      step: StateFile::Questions::InitiateDataTransferController
    },
    {
      title: "Section 5: Complete your state tax return",
      step: StateFile::Questions::DataReviewController
    },
    {
      title: "Section 6: Submit your state taxes",
      step: StateFile::Questions::ReturnStatusController
    }
  ]

  def initialize(navigator)
    @navigator = navigator
  end

  def get_progress(controller, current_controller)
    step_number = get_step_number(controller)
    number_of_steps = get_number_of_steps(controller)
    (step_number * 100.0 / number_of_steps).round
  end

  def get_section(controller)
    controllers = @navigator.controllers
    controller_index = controllers.index(controller)
    section = SECTIONS.detect { |section| controllers.index(section[:step]) <= controller_index }
    return section if section.nil? or section[:step] == controller
    section_index = SECTIONS.index(section)
    SECTIONS[section_index-1]
  end

  def get_step_number(controller)
    section = get_section(controller)
    if section
      controllers = @navigator.controllers
      index = controllers.index(controller)
      section_index = controllers.index(section[:step])
      index - section_index
    end
  end

  def get_number_of_steps(controller)
    section = get_section(controller)
    if section
      section_index = SECTIONS.index(section)
      next_section = SECTIONS[section_index+1]
      controllers = @navigator.controllers
      controller_index = controllers.index(section[:step])
      next_section_index = next_section ? controllers.index(next_section[:step]) : controllers.length
      next_section_index - controller_index
    end
  end

  def get_progress_title(controller)
    section = get_section(controller)
    #I18n.t("views.shared.progress_bar.progress_text")
    section[:title]
  end
end


class Section
  attr_accessor :title, :first_step, :number_of_steps
  def initialize(title, first_step, number_of_steps: nil)
    @title = title
    @first_step = first_step
    @number_of_steps =
  end
end
