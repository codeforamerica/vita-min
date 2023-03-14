module DocumentTypes
  class PermanentResidentCard < DocumentType
    class << self
      def relevant_to?(_intake)
        false # only used as an alternative ID type
      end

      def key
        "Permanent Resident Card"
      end
    end
  end
end
