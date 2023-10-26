module StateFile
  class AzDependentsDobForm < QuestionsForm
    include DateHelper

    attr_accessor :dependents_attributes

    validate :valid_months_in_home
    # validate :birth_date_is_valid_date

    def initialize(intake, form_params = nil)
      @intake = intake
      @params = form_params
    end

    def dependents
      @intake.dependents
    end

    def save
      return false unless valid?

      @params.to_h["dependents_attributes"].each do |_k, attrs|
        dependent = @intake.dependents.find(attrs["id"].to_i)
        next unless dependent
        months_in_home = attrs["months_in_home"].to_i
        dob = parse_date_params(attrs["dob_year"], attrs["dob_month"], attrs["dob_day"])
        dependent.update!(months_in_home: months_in_home, dob: dob)
      end
    end

    def valid?
      form_valid = super
      # binding.pry
      dependents_valid = dependents.map { |d| d.valid?(:az_dependent_dob_form) }
      form_valid && !dependents_valid.include?(false)
    end

    private

    def valid_months_in_home
      @params.to_h["dependents_attributes"].each do |_k, attrs|
        self.errors.add("months_in_home_#{_k}", "Missing months in home") if attrs["months_in_home"].empty?
        self.errors.add("months_in_home_#{_k}", "Value is not a number between 0 and 12") unless attrs["months_in_home"].to_i.between?(0, 12)
      end
      return false if self.errors.any?
    end

    # def birth_date_is_valid_date
    #   @params.to_h["dependents_attributes"].each do |_k, attrs|
    #     self.errors.add("dob_#{_k}", "not valid date") if valid_text_birth_date(attrs["dob_year"], attrs["dob_month"], 1, attrs["dob_day"])
    #   end
    # end

    def self.from_intake(intake)
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(intake, existing_attributes(intake).slice(*attribute_keys))
    end

  end
end