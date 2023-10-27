module StateFile
  class NyDobForm < QuestionsForm
    include DateHelper
    set_attributes_for :birthday,
                       :primary_birth_date_month, :primary_birth_date_day, :primary_birth_date_year,
                       :spouse_birth_date_month, :spouse_birth_date_day, :spouse_birth_date_year
    attr_accessor :dependents_attributes
    validate :primary_birth_date_is_valid_date

    def initialize(intake, form_params = nil)
      @intake = intake
      @params = form_params
      super
    end

    def dependents
      @intake.dependents
    end

    def save
      @intake.assign_attributes(state_file_dependents_attributes: formatted_dependents_attributes,
                                primary_birth_date: primary_birth_date,
                                spouse_birth_date: spouse_birth_date)
      @intake.save!
    end

    def valid?
      # need to call save before valid? otherwise will be looking for missing dob before they have been saved
      form_valid = super
      dependents_valid = dependents.map { |d| d.valid?(:dob_form) }
      form_valid && !dependents_valid.include?(false)
    end

    def self.existing_attributes(intake)
      attributes = super
      if intake.primary_birth_date.present?
        attributes.merge!(
          primary_birth_date_day: intake.primary_birth_date.day,
          primary_birth_date_month: intake.primary_birth_date.month,
          primary_birth_date_year: intake.primary_birth_date.year,
        )
      end
      if intake.spouse_birth_date.present?
        attributes.merge!(
          spouse_birth_date_day: intake.spouse_birth_date.day,
          spouse_birth_date_month: intake.spouse_birth_date.month,
          spouse_birth_date_year: intake.spouse_birth_date.year,
          )
      end
      attributes
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

    def primary_birth_date
      parse_date_params(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day)
    end

    def spouse_birth_date
      parse_date_params(spouse_birth_date_year, spouse_birth_date_month, spouse_birth_date_day)
    end

    def primary_birth_date_is_valid_date
      valid_text_birth_date(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day, :primary_birth_date)
    end
  end
end