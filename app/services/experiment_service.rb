class ExperimentService
  ID_VERIFICATION_EXPERIMENT = "id_verification_experiment"
  DIY_SUPPORT_LEVEL_EXPERIMENT = "diy_high_and_low_experiment"
  RETURNING_CLIENT_EXPERIMENT = "returning_client_experiment"

  CONFIG = {
    DIY_SUPPORT_LEVEL_EXPERIMENT => {
      name: "File Myself Support experiment",
      treatment_weights: {
        low: 1,
        high: 1
      },
    },
    ID_VERIFICATION_EXPERIMENT => {
      name: "Easier ID Verification experiment",
      treatment_weights: {
        control: 1,
        no_selfie: 1,
        expanded_id: 1,
        expanded_id_and_no_selfie: 1,
      }
    },
    RETURNING_CLIENT_EXPERIMENT => {
      name: "Return Clients experiment",
      treatment_weights: {
        control: 1,
        skip_identity_documents: 1
      }
    }
  }

  def self.find_or_assign_treatment(key:, record:, vita_partner_id: nil)
    experiment = Experiment.find_by(key: key)
    return unless experiment&.enabled
    if vita_partner_id.present?
      vita_partner = VitaPartner.find(vita_partner_id)
      ids_to_check = [vita_partner.id, vita_partner.parent_organization&.id].compact
      return unless experiment.vita_partner_ids.intersect?(ids_to_check)
    end

    participant = ExperimentParticipant.find_by(experiment: experiment, record: record)
    return participant.treatment if participant

    treatment = TreatmentChooser.new(CONFIG[key][:treatment_weights]).choose
    participant = ExperimentParticipant.create!(experiment: experiment, record: record, treatment: treatment)
    participant.treatment
  end

  class TreatmentChooser
    def initialize(treatment_weights)
      sum_of_probability = treatment_weights.values.reduce(0) { |a, b| a + b }
      cumulative_probability = 0.0
      @use_probabilities = []
      treatment_weights.each do |value, probability|
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
      ap experiment
      if experiment.name.blank?
        experiment.update(name: CONFIG[key][:name])
      end
    end
  end
end