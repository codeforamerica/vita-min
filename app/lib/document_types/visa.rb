module DocumentTypes
  class Visa < DocumentType
    class << self
      def relevant_to?(_intake)
        false # only used as an alternative ID type
      end

      def key
        "Visa"
      end
    end
  end
end
