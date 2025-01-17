module StateFile
  module ArchivedIntakes
    class IdentificationNumberForm < Form
      attr_accessor :ssn, :archived_intake_request
      validates :ssn, presence: true

      def initialize(archived_intake_request, attributes = {})
        super(attributes)
        @ssn = attributes[:ssn]
        @archived_intake_request = archived_intake_request
      end

      def valid?
        super
        return false unless ssn.present?

        hashed_ssn = SsnHashingService.hash(parsed_ssn)

        archived_intake_ssn = @archived_intake_request&.state_file_archived_intake&.hashed_ssn

        valid_ssn = hashed_ssn == archived_intake_ssn

        unless valid_ssn
          errors.add(:ssn, I18n.t("state_file.archived_intakes.identification_numbeer.edit.error_message"))
        end

        valid_ssn
      end

      def parsed_ssn
        ssn.remove(/\D/)
      end
    end
  end
end
