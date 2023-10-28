module StateFile
  class DobForm < QuestionsForm
    include DateHelper
    attr_accessor :dependents_attributes
    attr_reader :intake

    delegate :ask_months_in_home?, :ask_primary_dob?, :ask_spouse_dob?, to: :intake

    validate :primary_birth_date_is_valid_date, if: -> { @intake.ask_primary_dob? }
    validate :spouse_birth_date_is_valid_date, if: -> { @intake.ask_spouse_dob? }

    set_attributes_for :intake,
                       :primary_birth_date_month, :primary_birth_date_day, :primary_birth_date_year,
                       :spouse_birth_date_month, :spouse_birth_date_day, :spouse_birth_date_year

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
      attributes_to_update = { dependents_attributes: formatted_dependents_attributes }
      attributes_to_update[:primary_birth_date] = primary_birth_date if @intake.ask_primary_dob?
      attributes_to_update[:spouse_birth_date] = spouse_birth_date if @intake.ask_spouse_dob?
      @intake.update!(attributes_to_update)
    end

    def valid?
      form_valid = super
      dependents_valid = dependents.map { |d| d.valid?(:dob_form) }
      form_valid && !dependents_valid.include?(false)
    end

    def self.existing_attributes(intake)
      attributes = super
      if intake.ask_primary_dob?
        attributes.merge!(
          primary_birth_date_day: intake.primary_birth_date&.day,
          primary_birth_date_month: intake.primary_birth_date&.month,
          primary_birth_date_year: intake.primary_birth_date&.year,
        )
      end
      if intake.ask_spouse_dob?
        attributes.merge!(
          spouse_birth_date_day: intake.spouse_birth_date&.day,
          spouse_birth_date_month: intake.spouse_birth_date&.month,
          spouse_birth_date_year: intake.spouse_birth_date&.year,
        )
      end
      attributes
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

    def primary_birth_date
      parse_date_params(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day)
    end

    def spouse_birth_date
      parse_date_params(spouse_birth_date_year, spouse_birth_date_month, spouse_birth_date_day)
    end

    def primary_birth_date_is_valid_date
      valid_text_birth_date(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day, :primary_birth_date)
    end

    def spouse_birth_date_is_valid_date
      valid_text_birth_date(spouse_birth_date_year, spouse_birth_date_month, spouse_birth_date_day, :spouse_birth_date)
    end
  end
end