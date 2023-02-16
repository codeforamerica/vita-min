class ExperimentService
  DIY_SUPPORT_LEVEL_EXPERIMENT = "diy_high_and_low_experiment"

  CONFIG = {
    DIY_SUPPORT_LEVEL_EXPERIMENT => {
      name: "DIY high and low support experiment",
      alternatives: {
        low: 1,
        high: 1
      }
    }
  }

  def self.find_or_assign_treatment(key:, record:)
    experiment = Experiment.find_by(key: key)
    return unless experiment&.enabled
    participant = ExperimentParticipant.find_by(experiment: experiment, record: record)
    return participant.treatment if participant

    treatment = TreatmentChooser.new(CONFIG[key][:alternatives]).choose
    participant = ExperimentParticipant.create!(experiment: experiment, record: record, treatment: treatment)
    participant.treatment
  end

  class TreatmentChooser
    def initialize(alternatives)
      sum_of_probability = alternatives.values.reduce(0) { |a, b| a + b }
      cumulative_probability = 0.0
      @use_probabilities = []
      alternatives.each_with_index do |(value, probability), i|
        probability = probability.to_f / sum_of_probability
        @use_probabilities << [value, cumulative_probability += probability]
      end
    end

    def choose
      random_outcome = rand
      @use_probabilities.each do |value, max_prob|
        return value if random_outcome < max_prob
      end
    end
  end

  def self.ensure_experiments_exist_in_database
    CONFIG.each do |key, _details|
      experiment = Experiment.find_or_create_by(key: key)
      if experiment.name.blank?
        experiment.update(name: CONFIG[key][:name])
      end
    end
  end
end