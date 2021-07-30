class IntakeProgressCalculator

  starting_index = QuestionNavigation::FLOW.index(Questions::LifeSituationsController)
  ending_index = QuestionNavigation::FLOW.index(Questions::SuccessfullySubmittedController)
  question_steps = QuestionNavigation::FLOW[starting_index..ending_index]
  doc_overview_index = question_steps.index(Questions::OverviewDocumentsController)

  POSSIBLE_STEPS = question_steps.insert(doc_overview_index + 1, *DocumentNavigation::FLOW)

  def self.show_progress?(controller_class)
    POSSIBLE_STEPS.include? controller_class
  end

  def self.get_progress(controller, current_controller)
    return 0 if controller == POSSIBLE_STEPS.first

    # The DependentsController is not in the QuestionsFlow, so we hold progress at the HadDependentsController until they move on
    if controller == DependentsController
      controller = Questions::HadDependentsController
    end

    # From the Documents::OverviewController the user has the option to go add any relevant but optional documents
    # Pin the progress bar to the OverviewController for these optional document controllers
    intake = current_controller.visitor_record
    if !controller.show?(intake) && controller.respond_to?(:document_type) && controller.document_type.relevant_to?(intake)
      controller = Documents::OverviewController
    end

    steps_for_intake = POSSIBLE_STEPS.select do |controller_step|
      controller_step.show?(controller_step.model_for_show_check(current_controller))
    end
    current_index = steps_for_intake.index(controller)

    # If the currently viewed controller is not found in the possible steps, return a -1 so we can gracefully not show
    # it rather than causing a broken page
    if current_index.nil?
      return -1
    end

    completed_steps = current_index + 1 # Everything that the client has done
    index_of_intake_steps = steps_for_intake.index(controller)
    remaining_steps = steps_for_intake[index_of_intake_steps + 1..-1].length # Everything the client could potentially do

    ((completed_steps/(completed_steps + remaining_steps.to_f)) * 100).round
  end
end
