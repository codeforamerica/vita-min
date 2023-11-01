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
      @intake.dependents.az_qualifying_senior
    end

    def save
      @intake.update!({ dependents_attributes: dependents_attributes.to_h })
    end

    def valid?
      is_valid = super && dependents.all? { |d| d.valid?(:az_senior_form) }
      binding.pry
      is_valid
    end
  end
end