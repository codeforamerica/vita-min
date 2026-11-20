module DocumentTypes
  class EmailAttachment < DocumentType
    class << self
      def key
        "Email Attachment"
      end

      def blocks_progress?
        false
      end
    end
  end
end
