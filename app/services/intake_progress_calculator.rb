class IntakeProgressCalculator

  starting_index = QuestionNavigation::FLOW.index(Questions::BacktaxesController)
  question_steps = QuestionNavigation::FLOW[starting_index..-1]
  doc_overview_index = question_steps.index(Questions::OverviewDocumentsController)
  POSSIBLE_STEPS = question_steps.insert(doc_overview_index + 1, *DocumentNavigation::FLOW)

  def get_progress(controller, intake)
    return 0 if controller == POSSIBLE_STEPS.first

    if controller == DependentsController
      controller = Questions::HadDependentsController
    end

    current_flow = POSSIBLE_STEPS.select do |controller_step|
      controller_step.show?(intake)
    end
    current_index = current_flow.index(controller)
    ((current_index + 1)/current_flow.count.to_f * 100).round
  end
end
