module DocumentTypes
  class IrsIpPinLetter < DocumentType
    class << self
      def relevant_to?(_intake)
        true #Set to always true until rules are implemented. This ensures that the type always shows in the meantime
      end

      def key
        "IRS IP PIN Letter"
      end
    end
  end
end
