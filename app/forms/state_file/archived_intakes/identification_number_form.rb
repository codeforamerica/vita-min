module StateFile
  module ArchivedIntakes
    class IdentificationNumberForm < Form
      # TODO: bring in arhived intake request
      attr_accessor :ssn, :ip_for_irs
      validates :ssn, presence: true

      def valid?
        super
        return false unless ssn.present?

        hashed_ssn = SsnHashingService.hash(ssn)
        valid_ssn = ArchivedIntake.find_by(
          email_address: session[:email_address], # does this work?
          hashed_ssn: hashed_ssn
        ).exists?

        unless valid_ssn
          errors.add(:ssn, I18n.t("state_file.archived_intakes.identification_number.edit.error_message"))
        end

        valid_ssn
      end
    end
  end
end
