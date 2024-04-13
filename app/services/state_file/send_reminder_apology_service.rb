module StateFile
  class SendReminderApologyService
    def self.run

      intakes = EfileSubmission.joins(:efile_submission_transitions)
                     .for_state_filing
                     .where("efile_submission_transitions.to_state = 'accepted'")
                     .where("efile_submission_transitions.to_state = 'transmitted'")
                     .extract_associated(:data_source)

      intakes.each do |intake|
        SendReminderApologyMessageJob.perform_later(intake)
      end
    end
  end
end
