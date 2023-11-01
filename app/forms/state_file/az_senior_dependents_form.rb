module StateFile
  class AzSeniorDependentsForm < QuestionsForm
    attr_accessor :dependents_attributes
    attr_reader :intake

    def initialize(intake = nil, params = nil)
      super
      if params.present?
        @intake.assign_attributes(dependents_attributes: dependents_attributes.to_h)
      end
    end

    def dependents
      @intake.dependents.select(&:ask_senior_questions?)
    end

    def save
      @intake.update!({ dependents_attributes: dependents_attributes.to_h })
    end

    def valid?
      form_valid = super
      dependents_attributes.each do |_index, dependent_attributes|
        form_valid = false if dependent_attributes[:needed_assistance].nil? || dependent_attributes[:needed_assistance] == "unfilled" || dependent_attributes[:passed_away].nil? || dependent_attributes[:passed_away] == "unfilled"
      end
      # TODO: real error handling
      errors.add(:base, "You must select a value") unless form_valid
      form_valid
    end

  end
end