class DocumentRequirement
  attr_reader :document_type, :accepted_document_types, :needed_for

  def initialize(document_type, required:, accepted_document_types: [document_type], needed_for: [:primary], offer_doc_help: false, &applies_if)
    @document_type = document_type
    @required = required
    @accepted_document_types = accepted_document_types
    @needed_for = needed_for
    @offer_doc_help = offer_doc_help
    @applies_if = applies_if
  end

  def key
    document_type.key
  end

  def applies_to?(intake)
    @applies_if.call(intake)
  end

  def required?
    @required
  end

  def recommended?
    !required?
  end

  def offer_doc_help?
    @offer_doc_help
  end

  def satisfied_by?(document_type_key)
    accepted_document_types.any? { |accepted_type| accepted_type.key == document_type_key }
  end

  def required_persons(intake)
    persons = []
    persons << intake.primary if needed_for.include?(:primary)
    persons << intake.spouse if needed_for.include?(:spouse) && intake.filing_joint_yes?
    persons.concat(intake.dependents) if needed_for.include?(:dependents) && intake.dependents.present?
    persons
  end
end
