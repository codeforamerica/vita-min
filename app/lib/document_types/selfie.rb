module DocumentTypes
  class Selfie < DocumentType
    class << self
      def relevant_to?(intake)
        !IdVerificationExperimentService.new(intake).skip_selfies?
      end

      def key
        "Selfie"
      end

      def needed_if_relevant?
        true
      end

      def blocks_progress?
        true
      end

      def provide_doc_help?
        true
      end

      def needed_for_spouse
        true
      end
    end
  end
end
