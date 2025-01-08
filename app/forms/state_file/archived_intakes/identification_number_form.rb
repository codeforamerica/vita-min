module StateFile
  module ArchivedIntakes
    class IdentificationNumberForm < Form
      validates :ssn, social_security_number: true, presence: true

      def initialize(attributes = {})
        super
        assign_attributes(attributes)
      end

      def save
        run_callbacks :save do
          valid?
        end
      end
    end
  end
end
