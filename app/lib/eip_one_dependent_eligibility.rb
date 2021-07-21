class EipOneDependentEligibility
  CUT_OFF_BIRTHDATE = Date.new(2004, 1, 1)

  def initialize(birthdate:, relationship:)
    @birthdate = birthdate
    @relationship = relationship
  end

  def self.eligible?(*args)
    new(*args).eligible?
  end

  def eligible?
    qualifying_relationship? && eligible_age?
  end

  private

  def qualifying_relationship?
    ChildRelationshipQualifier.qualifies?(relationship: @relationship)
  end

  def eligible_age?
    CUT_OFF_BIRTHDATE <= @birthdate
  end
end
