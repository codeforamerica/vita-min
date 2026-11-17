module DocumentTypes
  class Form15080 < DocumentType
    class << self
      def key
        "Consent Form 15080"
      end

      def blocks_progress?
        false
      end
    end
  end
end
