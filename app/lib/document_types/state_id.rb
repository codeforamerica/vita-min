module DocumentTypes
  class StateId < DocumentType
    class << self
      def relevant_to?(_intake)
        false # only used as an alternative ID type
      end

      def key
        "State ID"
      end
    end
  end
end
