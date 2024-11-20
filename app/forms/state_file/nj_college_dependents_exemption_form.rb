module StateFile
  class NjCollegeDependentsExemptionForm < QuestionsForm
    attr_accessor :dependents_attributes
    delegate :dependents, to: :intake

    set_attributes_for(:intake)

    def save
      @intake.update!(attributes_to_save)
    end

    def attributes_to_save
      base_attrs = attributes_for(:intake)
      base_attrs.merge({ dependents_attributes: dependents_attributes.to_h })
    end
  end
end