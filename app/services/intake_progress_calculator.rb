class IntakeProgressCalculator

  starting_index = QuestionNavigation::FLOW.index(Questions::LifeSituationsController)
  ending_index = QuestionNavigation::FLOW.index(Questions::AdditionalInfoController)
  POSSIBLE_STEPS = QuestionNavigation::FLOW[starting_index..ending_index]

  def self.show_progress?(controller_class)
    POSSIBLE_STEPS.include? controller_class
  end

  def self.get_progress(controller, intake)
    return 0 if controller == POSSIBLE_STEPS.first

    # The DependentsController is not in the QuestionsFlow, so we hold progress at the HadDependentsController until they move on
    if controller == DependentsController
      controller = Questions::HadDependentsController
    end

    steps_for_intake = POSSIBLE_STEPS.select do |controller_step|
      controller_step.show?(intake)
    end
    current_index = steps_for_intake.index(controller)
    completed_steps = current_index + 1 # Everything that the client has done

    index_of_possible_steps = POSSIBLE_STEPS.index(controller)
    possible_remaining_steps = POSSIBLE_STEPS[index_of_possible_steps + 1..-1].length # Everything the client could potentially do

    ((completed_steps/(completed_steps + possible_remaining_steps.to_f)) * 100).round
  end
end
