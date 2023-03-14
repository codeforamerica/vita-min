module DocumentTypes
  class TribalId < DocumentType
    class << self
      def relevant_to?(_intake)
        false # only used as an alternative ID type
      end

      def key
        "Tribal ID"
      end
    end
  end
end
