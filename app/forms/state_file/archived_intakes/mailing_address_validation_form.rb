module StateFile
  module ArchivedIntakes
    class MailingAddressValidationForm < Form
      attr_accessor :addresses, :current_address, :selected_address

      validates :chosen_address, presence: true
      def initialize(attributes = {}, addresses: [], current_address: nil)
        super(attributes)
        @addresses = addresses
        @current_address = current_address
      end

      def valid?
        binding.pry
        selected_address == current_address
      end
    end
  end
end