module DocumentTypes
  class CompletedForm8879 < DocumentType
    class << self
      def key
        "Form 8879 (Signed)"
      end

      def blocks_progress?
        false
      end
    end
  end
end