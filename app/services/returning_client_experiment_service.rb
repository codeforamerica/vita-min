class ReturningClientExperimentService
  def initialize(intake)
    @intake = intake
  end

  def skip_identity_documents?
    treatment == 'skip_identity_documents'
  end

  def documents_not_needed
    skip_identity_documents? ? [DocumentTypes::Identity, DocumentTypes::SecondaryIdentification::Ssn, DocumentTypes::SecondaryIdentification::Itin, DocumentTypes::Selfie] : []
  end

  private

  def treatment
    experiment = Experiment.find_by(key: ExperimentService::RETURNING_CLIENT_EXPERIMENT)
    return unless experiment

    # Hub list pages preload participants; only use the association when it's already loaded, since
    # ExperimentService can create a participant after it was loaded. Archived intakes don't have it.
    participants = @intake.try(:experiment_participants)
    participant = if participants&.loaded?
                    participants.find { |ep| ep.experiment_id == experiment.id }
                  else
                    ExperimentParticipant.find_by(experiment: experiment, record: @intake)
                  end
    participant&.treatment
  end
end