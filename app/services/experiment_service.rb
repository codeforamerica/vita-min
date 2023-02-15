class ExperimentService
  DIY_SUPPORT_LEVEL_EXPERIMENT = "DIY high and low level support experiment"

  CONFIG = {
    DIY_SUPPORT_LEVEL_EXPERIMENT => {
      low: 1,
      high: 1
    }
  }

  def self.find_or_assign_treatment(experiment_id:, record:)
    participant = ExperimentParticipant.find_by(experiment_id: experiment_id, record: record)
    return participant.treatment if participant

    treatment = TreatmentChooser.new(CONFIG[experiment_id]).choose
    participant = ExperimentParticipant.create!(experiment_id: experiment_id, record: record, treatment: treatment)
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
end