class Dependent::Rules
  attr_reader :age, :birth_date, :tax_year, :dependent
  def initialize(dependent, tax_year)
    @dependent = dependent
    @tax_year = tax_year
    @birth_date = @dependent.birth_date
  end

  def born_in_final_6_months?
    birth_date >= Date.new(tax_year, 6, 30) && birth_date <= Date.new(tax_year, 12, 31)
  end

  # For tax year e.g. 1999, someone is 1 year old if born on any day in 1998.
  def age
    @age ||= tax_year - birth_date.year
  end

  def qualifying_child_relationship?
    dependent.qualifying_child_relationship?
  end

  def qualifying_relative_relationship?
    dependent.qualifying_relative_relationship?
  end

  def meets_qc_age_condition?
    return false if age.negative?
    
    dependent.permanently_totally_disabled_yes? || age < 19 || (dependent.full_time_student_yes? && age < 24)
  end

  def disqualified_child_qualified_relative?
    return false if age.negative?

    qualifying_child_relationship? && !meets_qc_age_condition?
  end

  def qualifying_relative?
    dependent.meets_misc_qualifying_relative_requirements_yes? &&
      dependent.ssn.present? &&
      (disqualified_child_qualified_relative? || qualifying_relative_relationship?)
  end

  def meets_qc_residence_condition?
    dependent.meets_qc_residence_condition_generic? || born_in_final_6_months?
  end

  def qualifying_child?
    qualifying_child_relationship? &&
      dependent.ssn.present? &&
      dependent.meets_qc_claimant_condition? &&
      dependent.meets_qc_misc_conditions? &&
      meets_qc_age_condition? &&
      meets_qc_residence_condition?
  end
end
