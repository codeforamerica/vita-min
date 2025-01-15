module StateFile
  module ArchivedIntakes
    class IdentificationNumberForm < Form
      attr_accessor :ssn, :ip_for_irs
      validates :ssn, presence: true

      def valid?
        super
        return false unless ssn.present?

        hashed_ssn = SsnHashingService.hash(ssn)
        valid_ssn = ArchivedIntake.find_by(
          email_address: session[:email_address],
          hashed_ssn: hashed_ssn
        ).exists?

        unless valid_ssn
          track_failed_attempt
          add_appropriate_error
        end

        valid_ssn
      end

      private

      def track_failed_attempt
        StateFileArchivedIntakeAccessLog.create!(
          ip_address: ip_for_irs,
          event_type: 5,
          created_at: Time.current
        )
      end

      def add_appropriate_error
        attempts = StateFileArchivedIntakeAccessLog.where(
          ip_address: ip_for_irs,
          event_type: 5,
          created_at: Time.current..5.hours.ago
        ).count

        if attempts >= 2
          errors.add(:no_remaining_attempts, true)
        else
          errors.add(:ssn, I18n.t("state_file.archived_intakes.identification_number.edit.error_message"))
        end
      end
    end
  end
end
