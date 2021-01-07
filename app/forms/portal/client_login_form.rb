module Portal
  class ClientLoginForm < Form
    attr_accessor :last_four_ssn, :confirmation_number, :token
  end
end