module StateFile
  module ArchivedIntakes
    class IdentificationNumberForm < Form
      attr_accessor :ssn, :archived_intake_ssn, :ip_for_irs # maybe delete IP, unclear
      validates :ssn, presence: true

      def initialize(attributes = {}, archived_intake_ssn = nil)
        super()
        @ssn = attributes[:ssn]
        @archived_intake_ssn = archived_intake_ssn
      end

      def valid?
        super
        return false unless ssn.present?

        hashed_ssn = SsnHashingService.hash(parsed_ssn)

        valid_ssn = hashed_ssn == @archived_intake_ssn

        unless valid_ssn
          errors.add(:ssn, I18n.t("state_file.archived_intakes.identification_number.edit.error_message"))
        end

        valid_ssn
      end

      def parsed_ssn
        ssn.remove(/\D/)
      end
    end
  end
end
