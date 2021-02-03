class GenerateConsentDocuments
  def create_consent_docs
    # GenerateConsentDocuments.new.create_consent_docs
    # Document.all.where(document_type: DocumentTypes::ConsentForm14446.key).map(&:destroy)
    intakes_without_consent_doc = []
    successes = []
    problems = []

    Intake.all.each do |intake|
      consent_form_exists = false

      intake.documents.each do |doc|
        if doc.document_type == DocumentTypes::ConsentForm14446.key
          consent_form_exists = true
        end
      end

      intakes_without_consent_doc << intake.id unless consent_form_exists
    end

    intakes_without_consent_doc.each do |intake_id|
      begin
        consent_doc = Intake.find(intake_id).create_consent_document
        successes << "Created consent document for intake #{intake_id}" unless consent_doc.nil?
      rescue => e
        problems << "SKIPPED could not create consent document for #{intake_id} because #{e.message}"
      end
    end

    puts "*****************INTAKES WITHOUT CONSENT: #{intakes_without_consent_doc}"
    puts "**** #{successes.length} SUCCESSES ****"
    puts successes
    puts "**** LOOK INTO THESE #{problems.length} ISSUES ****"
    puts problems
  end
end
