module DocumentTypes
  class EmployerId < DocumentType
    class << self
      def relevant_to?(_intake)
        false # only used as an alternative ID type
      end

      def key
        "Employer ID"
      end
    end
  end
end
