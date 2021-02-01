module DocumentTypes
  class ConsentForm14446 < DocumentType
    class << self
      def relevant_to?(_intake)
        # This is not used in a flow or to determine relevant types for an intake
        false
      end

      def key
        "Consent Form 14446"
      end
    end
  end
end
