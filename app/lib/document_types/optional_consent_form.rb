module DocumentTypes
  class OptionalConsentForm < DocumentType
    class << self
      def key
        "Optional Consent Form"
      end

      def blocks_progress?
        false
      end
    end
  end
end
