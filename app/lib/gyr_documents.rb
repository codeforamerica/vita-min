module GyrDocuments
  def has_all_required_docs?(intake)
    DocumentChecklist.new(intake).all_required_satisfied?
  end

  def next_intake_state(intake)
    has_all_required_docs?(intake) ? :intake_ready : :intake_needs_doc_help
  end

  def intake_transition_to(intake, next_state, when_current_is: nil, auto_advanced_flag: false)
    # `when_current_is` -- list of states as symbols; will only transition a return
    # whe current state is included in this list.
    intake.tax_returns.each do |tax_return|
      if when_current_is
        if tax_return.current_state.to_sym != next_state &&
            (when_current_is.include? tax_return.current_state.to_sym)
          tax_return.transition_to(next_state) 
          tax_return.was_auto_advanced = auto_advanced_flag
        end
      else
        if tax_return.current_state.to_sym != next_state
          tax_return.transition_to(next_state) 
          tax_return.was_auto_advanced = auto_advanced_flag
        end
      end
    end
  end
end
