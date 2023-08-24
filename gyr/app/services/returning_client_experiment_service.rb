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
    ExperimentParticipant.find_by(experiment: experiment, record: @intake)&.treatment
  end
end