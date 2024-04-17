module StateFile
  class IntakeLoginForm < Form
    attr_accessor :ssn, :possible_intakes
    before_validation :possible_intakes_present
    validates :ssn, social_security_number: true, presence: true
    validate :matches_intake

    def intake
      return unless valid?

      @intake
    end

    def intake_to_log_in(matching_intakes)
      with_accepted_submissions = matching_intakes.filter { |intake| intake.latest_submission&.in_state?(:accepted) }
      if with_accepted_submissions.present?
        with_accepted_submissions.first
      else
        matching_intakes.first
      end
    end

    private

    def matches_intake
      @intake = intake_to_log_in(possible_intakes.where(hashed_ssn: SsnHashingService.hash(parsed_ssn)))
      if @intake.blank?
        errors.add(:ssn, I18n.t("state_file.intake_logins.form.errors.bad_input"))
        errors.add(:failed_ssn_match)
      end
    end

    def possible_intakes_present
      raise ArgumentError.new("Form requires at least one possible intake.") if possible_intakes.blank?
    end

    def parsed_ssn
      ssn.remove(/\D/)
    end
  end
end