module DocumentTypes
  class Other < DocumentType
    class << self
      def relevant_to?(_intake)
        true
      end

      def key
        "Other"
      end

      def skip_dont_have?
        true
      end
    end
  end
end
