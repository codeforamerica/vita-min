class GenerateConsentDocuments
  def create_consent_docs
    # GenerateConsentDocuments.new.create_consent_docs
    intakes_without_consent_doc = []
    successes = []
    problems = []

    Intake.all.each do |intake|
      consent_form_exists = false

      intake.documents.each do |doc|
        if doc.document_type == DocumentTypes::Form14446.key
          consent_form_exists = true
        end
      end

      intakes_without_consent_doc << intake.id unless consent_form_exists || intake.primary_consented_to_service_at.nil?
    end

    intakes_without_consent_doc.each do |intake_id|
      begin
        intake = Intake.find(intake_id)
        file_name = "Consent Form 14446.pdf"
        consent_doc = intake.update_or_create_14446_document(file_name)
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
