module DocumentTypes
  class DocumentType
    class << self
      def relevant_to?(_intake)
        raise NotImplementedError "Child classes must define when they are relevant to an intake"
      end

      def key
        raise NotImplementedError "A key must be defined in child classes"
      end

      # If you're on a page asking for this document, do we allow you to proceed?
      def blocks_progress?
        false
      end

      # Are we quite sure that, if this document is relevant to an intake, VITA won't interview you until
      # you have this document?
      def needed_if_relevant?
        false
      end
    end
  end
end
