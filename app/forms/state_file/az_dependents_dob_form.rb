module StateFile
  class AzDependentsDobForm < QuestionsForm
    include DateHelper
    attr_accessor :dependents_attributes

    def initialize(intake, form_params = nil)
      @intake = intake
      @params = form_params
      super
    end

    def dependents
      @intake.dependents
    end

    def save
      @intake.update!(state_file_dependents_attributes: formatted_dependents_attributes)
      @intake.save!
    end

    def valid?
      # need to call save before valid? otherwise will be looking for missing dob before they have been saved
      form_valid = super
      dependents_valid = dependents.map { |d| d.valid?(:dob_form) }
      form_valid && !dependents_valid.include?(false)
    end

    private

    def formatted_dependents_attributes
      dependents_attributes&.map { |k, v| [k, formatted_dependent_attrs(v)] }.to_h
    end

    def formatted_dependent_attrs(attrs)
      if attrs[:dob_month] && attrs[:dob_month] && attrs[:dob_year]
        attrs[:dob] = "#{attrs[:dob_year]}-#{attrs[:dob_month]}-#{attrs[:dob_day]}"
      end
      attrs.except!(:dob_month, :dob_day, :dob_year)
    end
  end
end