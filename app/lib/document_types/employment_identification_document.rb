module DocumentTypes
  class EmploymentIdentificationDocument < DocumentType
    class << self
      def relevant_to?(_intake)
        false # only used as an alternative ID type
      end

      def key
        "Employment Identification Document"
      end
    end
  end
end
