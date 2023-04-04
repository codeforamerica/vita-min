class IdVerificationExperimentService
  def initialize(intake)
    @intake = intake
  end

  def skip_selfies?
    %w[no_selfie expanded_id_and_no_selfie].include? treatment
  end

  def show_expanded_id?
    %w[expanded_id expanded_id_and_no_selfie].include? treatment
  end

  def documents_not_needed
    skip_selfies? ? [DocumentTypes::Selfie] : []
  end

  private

  def treatment
    experiment = Experiment.find_by(key: ExperimentService::ID_VERIFICATION_EXPERIMENT)
    return unless experiment
    ExperimentParticipant.find_by(experiment: experiment, record: @intake)&.treatment
  end
end
