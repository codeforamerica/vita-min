class CtcIntakeProgressCalculator
  starting_index = CtcQuestionNavigation::FLOW.index(Ctc::Questions::ContactPreferenceController)
  ending_index = CtcQuestionNavigation::FLOW.index(Ctc::Questions::ConfirmLegalController)
  POSSIBLE_STEPS = CtcQuestionNavigation::FLOW[starting_index..ending_index]

  def self.show_progress?(controller_class)
    POSSIBLE_STEPS.include? controller_class
  end

  def self.get_progress(controller, _current_controller)
    return 0 if controller == POSSIBLE_STEPS.first

    current_index = POSSIBLE_STEPS.index(controller)

    # If the currently viewed controller is not found in the possible steps, return a -1 so we can gracefully not show
    # it rather than causing a broken page
    if current_index.nil?
      return -1
    end

    completed_steps = current_index + 1 # Everything that the client has done
    remaining_steps = POSSIBLE_STEPS[current_index + 1..-1].length # Everything the client could potentially do

    ((completed_steps / (completed_steps + remaining_steps.to_f)) * 100).round
  end
end
