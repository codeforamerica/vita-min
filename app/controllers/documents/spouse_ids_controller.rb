module Documents
  class SpouseIdsController < IdsController
    def self.show?(intake)
      intake.filing_jointly? && IdVerificationExperimentService.new(intake).show_expanded_id?
    end

    def documents
      current_intake.documents.of_type(self.class.displayed_document_types).where(person: :spouse)
    end

    def form_params
      super.merge(person: :spouse)
    end
  end
end
