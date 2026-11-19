module DocumentTypes
  class SsnItin < DocumentType
    class << self
      def description
        "Social Security cards are a valid SSN document"
      end

      def key
        "SSN or ITIN"
      end

      def blocks_progress?
        true
      end
    end
  end
end
