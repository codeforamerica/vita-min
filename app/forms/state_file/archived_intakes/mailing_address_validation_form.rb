module StateFile
  module ArchivedIntakes
    class MailingAddressValidationForm < Form
      attr_accessor :selected_address

      def initialize(attributes = {}, addresses: [], current_address: nil)
        super(attributes)
        @addresses = addresses
        @current_address = current_address
      end

      def valid?
        selected_address == @current_address
      end
    end
  end
end