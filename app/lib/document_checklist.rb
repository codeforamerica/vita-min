class DocumentChecklist
  attr_reader :requirements

  def initialize(intake, requirements: DocumentRequirements.new(intake))
    @intake = intake
    @requirements = requirements
  end

  def provided_count(requirement)
    uploaded_document_type_keys.count { |key| requirement.satisfied_by?(key) }
  end

  def satisfied?(requirement)
    provided_count(requirement).positive?
  end

  def missing_required
    requirements.required.reject { |requirement| satisfied?(requirement) }
  end

  def missing_recommended
    requirements.recommended.reject { |requirement| satisfied?(requirement) }
  end

  def all_required_satisfied?
    missing_required.empty?
  end

  private

  def uploaded_document_type_keys
    @uploaded_document_type_keys ||= begin
      documents = @intake.client&.documents
      if documents.nil?
        []
      elsif documents.loaded?
        # Hub list pages preload documents (Client.with_eager_loaded_associations);
        # filter in memory so each row doesn't issue its own query.
        documents.reject(&:archived?).map(&:document_type)
      else
        documents.active.pluck(:document_type)
      end
    end
  end
end
