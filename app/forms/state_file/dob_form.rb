module StateFile
  class DobForm < QuestionsForm
    include DateHelper
    attr_accessor :dependents_attributes
    attr_reader :intake

    delegate :ask_months_in_home?, to: :intake

    def initialize(intake = nil, params = nil)
      super
      if params.present?
        @intake.assign_attributes(dependents_attributes: formatted_dependents_attributes)
      end
    end

    def dependents
      @intake.dependents
    end

    def save
      @intake.update!(dependents_attributes: formatted_dependents_attributes)
    end

    def valid?
      form_valid = super
      dependents_valid = dependents.map { |d| d.valid?(:dob_form) }
      form_valid && !dependents_valid.include?(false)
    end

    private

    def formatted_dependents_attributes
      dependents_attributes&.map { |k, v| [k, formatted_dependent_attrs(v)] }.to_h
    end

    def formatted_dependent_attrs(attrs)
      if attrs[:dob_day] && attrs[:dob_month] && attrs[:dob_year]
        attrs[:dob] = "#{attrs[:dob_year]}-#{attrs[:dob_month]}-#{attrs[:dob_day]}"
      end
      attrs.except!(:dob_month, :dob_day, :dob_year)
    end
  end
end