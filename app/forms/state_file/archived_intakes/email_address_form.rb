module StateFile
  module ArchivedIntakes
    class EmailAddressForm < Form
      include FormAttributes

      attr_accessor :email_address
      before_validation_squish :email_address

      validates :email_address, presence: true, 'valid_email_2/email': true
    end
  end
end
