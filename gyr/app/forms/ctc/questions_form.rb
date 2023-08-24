module Ctc
  class QuestionsForm < ::QuestionsForm
    def self.from_intake(intake)
      new(intake, existing_attributes(intake, Attributes.new(scoped_attributes[:intake]).to_sym))
    end

    def self.existing_attributes(model, attribute_keys)
      HashWithIndifferentAccess[(attribute_keys || []).map { |k| [k, model.send(k)] }]
    end
  end
end
