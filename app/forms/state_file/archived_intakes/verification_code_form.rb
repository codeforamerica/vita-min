module StateFile
  module ArchivedIntakes
    class VerificationCodeForm < Form
      attr_accessor :verification_code

      validates :verification_code, presence: true

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
