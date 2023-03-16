class ReturningClientExperimentService
  def initialize(intake)
    @intake = intake
  end

  def skip_identity_documents?
    treatment == 'skip_identity_documents'
  end

  private

  def treatment
    experiment = Experiment.find_by(key: ExperimentService::RETURNING_CLIENT_EXPERIMENT)
    return unless experiment
    ExperimentParticipant.find_by(experiment: experiment, record: @intake)&.treatment
  end
end