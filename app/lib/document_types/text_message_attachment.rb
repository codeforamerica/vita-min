module DocumentTypes
  class TextMessageAttachment < DocumentType
    class << self
      def relevant_to?(intake)
        # This is not used in a flow or to determine relevant types for an intake
        false
      end

      def key
        "Text Message Attachment"
      end

      def blocks_progress?
        false
      end
    end
  end
end
