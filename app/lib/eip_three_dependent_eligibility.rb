class EipThreeDependentEligibility
  UNDER_NINETEEN_CUT_OFF_BIRTHDATE = Date.new(2002, 1, 1)
  UNDER_TWENTY_FOUR_CUT_OFF_BIRTHDATE = Date.new(1997, 1, 1)

  def initialize(dependent_birthdate:, disabled:, student:, filer_birthdate:)
    @dependent_birthdate = dependent_birthdate
    @disabled = disabled
    @student = student
    @filer_birthdate = filer_birthdate
  end

  def self.eligible?(*args)
    new(*args).eligible?
  end

  def eligible?
    return true if @disabled

    return true if under_nineteen?

    return true if @student && under_twenty_four? && younger_than_filer?

    return false
  end

  private

  def under_nineteen?
    UNDER_NINETEEN_CUT_OFF_BIRTHDATE <= @dependent_birthdate
  end

  def under_twenty_four?
    UNDER_TWENTY_FOUR_CUT_OFF_BIRTHDATE <= @dependent_birthdate
  end

  def younger_than_filer?
    @filer_birthdate < @dependent_birthdate
  end
end
