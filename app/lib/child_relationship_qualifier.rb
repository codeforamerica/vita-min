class ChildRelationshipQualifier
  QUALIFYING_RELATIONSHIPS = [
    "DAUGHTER",
    "SON",
    "STEPCHILD",
    "FOSTER CHILD",
    "GRANDCHILD",
    "NIECE",
    "NEPHEW",
    "HALF BROTHER",
    "HALF SISTER",
    "BROTHER",
    "SISTER"
  ]

  def self.qualifies?(relationship:)
    QUALIFYING_RELATIONSHIPS.include? relationship
  end
end
