module StateFile
  module ArchivedIntakes
    class EmailAddressForm < Form
      attr_accessor :email_address

      validates :email_address, 'valid_email_2/email': true
      validates :email_address, presence: true

      def initialize(attributes = {})
        binding.pry
        super
        assign_attributes(attributes)
      end

      def save
        binding.pry
        run_callbacks :save do
          if valid?
            # Logic to persist the form data or perform actions
            true
          else
            false
          end
        end
      end
    end
  end
end
