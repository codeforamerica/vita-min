module Portal
  class PrimarySignForm8879 < Form
    attr_accessor :primary_accepts_terms, :primary_confirms_identity, :ip, :transaction_failed
    validate :terms_accepted
    validate :identity_confirmed

    def initialize(tax_return, params = {})
      @tax_return = tax_return
      super(params)
    end

    def sign
      return false unless valid?

      begin
        @tax_return.sign_primary!(ip)
      rescue ::AlreadySignedError, ::FailedToSignReturnError, CombinePDF::ParsingError
        errors.add(:transaction_failed)
        false
      end
    end

    def self.permitted_params
      [:primary_accepts_terms, :primary_confirms_identity]
    end

    private

    def terms_accepted
      errors.add(:primary_accepts_terms, :blank) unless primary_accepts_terms == "yes"
    end

    def identity_confirmed
      errors.add(:primary_confirms_identity, :blank) unless primary_confirms_identity == "yes"
    end
  end
end