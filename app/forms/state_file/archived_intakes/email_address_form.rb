module StateFile
  module ArchivedIntakes
    class EmailAddressForm < Form
      attr_accessor :email_address

      validates :email_address, presence: true, 'valid_email_2/email': true

    end
  end
end
