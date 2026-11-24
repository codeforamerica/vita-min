module GyrDocuments
  def has_all_required_docs?(intake)
    DocumentChecklist.new(intake).all_required_satisfied?
  end

  def next_intake_state(intake)
    has_all_required_docs?(intake) ? :intake_ready : :intake_needs_doc_help
  end

  def intake_transition_to(intake, next_state, when_current_in = nil, flag_auto_advancement_when_next_in = nil)
    intake.tax_returns.each do |tax_return|
      if when_current_in
        tax_return.transition_to(next_state) if
          tax_return.current_state.to_sym != next_state &&
            when_current_in.include? tax_return.current_state
      else
        tax_return.transition_to(next_state) if tax_return.current_state.to_sym != next_state &&
      end
    end
  end
end
