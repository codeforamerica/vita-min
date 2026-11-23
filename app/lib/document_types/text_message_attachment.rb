module DocumentTypes
  class TextMessageAttachment < DocumentType
    class << self
      def key
        "Text Message Attachment"
      end

      def blocks_progress?
        false
      end
    end
  end
end
