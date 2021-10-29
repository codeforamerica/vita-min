# transition not_filing intakes back to intake in progress if that was their previous status.
class TransitionNotFilingService
  def self.run(client)
    transitionable_statuses = ["intake_in_progress"]
    if client.tax_returns.present?
      client.tax_returns.each do |tr|
        next unless tr.current_state == "file_not_filing"

        transitionable_statuses.each do |status|
          if tr.previous_transition.present? && tr.previous_transition.to_state == status
            tr.transition_to!(status)
          end
        end
      end
    end
  end
end
