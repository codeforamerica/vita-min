module DocumentTypes
  class IrsIpPinLetter < DocumentType
    class << self
      def relevant_to?(_intake)
        false #False to avoid polluting document_types_possibly_needed while rules are implemented
      end

      def key
        "IRS IP PIN Letter"
      end
    end
  end
end
