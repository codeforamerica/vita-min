module DocumentTypes
  class Other < DocumentType
    class << self
      def relevant_to?(_intake)
        true
      end

      def key
        "Other"
      end
    end
  end
end
