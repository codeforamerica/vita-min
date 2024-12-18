module Portal
  class SpouseSignForm8879 < Form
    attr_accessor :spouse_accepts_terms, :spouse_confirms_identity, :ip, :transaction_failed
    validate :terms_accepted
    validate :identity_confirmed

    def initialize(tax_return, params = {})
      @tax_return = tax_return
      super(params)
    end

    def sign
      return false unless valid?

      begin
        @tax_return.sign_spouse!(ip)
      rescue ::AlreadySignedError, ::FailedToSignReturnError, CombinePDF::ParsingError
        errors.add(:transaction_failed)
        false
      end
    end

    def self.permitted_params
      [:spouse_accepts_terms, :spouse_confirms_identity]
    end

    private

    def terms_accepted
      errors.add(:spouse_accepts_terms, :blank) unless spouse_accepts_terms == "yes"
    end

    def identity_confirmed
      errors.add(:spouse_confirms_identity, :blank) unless spouse_confirms_identity == "yes"
    end
  end
end