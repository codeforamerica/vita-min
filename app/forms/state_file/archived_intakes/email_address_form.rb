module StateFile
  module ArchivedIntakes
    class EmailAddressForm < Form
      attr_accessor :email_address

      validates :email_address, 'valid_email_2/email': true
      validates :email_address, presence: true

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
