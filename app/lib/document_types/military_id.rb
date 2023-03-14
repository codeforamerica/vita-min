module DocumentTypes
  class MilitaryId < DocumentType
    class << self
      def relevant_to?(_intake)
        false # only used as an alternative ID type
      end

      def key
        "Military ID"
      end
    end
  end
end
