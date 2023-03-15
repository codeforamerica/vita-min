module DocumentTypes
  class EmploymentAuthorizationDocument < DocumentType
    class << self
      def relevant_to?(_intake)
        false # only used as an alternative ID type
      end

      def key
        "Employment Authorization Document"
      end
    end
  end
end
