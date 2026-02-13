module DocumentTypes
  class Identity < DocumentType
    class << self
      def relevant_to?(intake)
        !ReturningClientExperimentService.new(intake).skip_identity_documents?
      end

      def description
        'All of the following are included as valid forms of photo IDs: Drivers License, Employer Ids,
        Employment Authorization Document,GreenCard, Military Ids, Passport, School Ids, StateIds, Tribal Ids, and Visas'
      end

      def key
        "ID"
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
