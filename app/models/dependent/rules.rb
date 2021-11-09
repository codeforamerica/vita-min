class Dependent::Rules
  def initialize(birth_date, tax_year, full_time_student_yes, permanently_totally_disabled_yes, ssn_present, qualifying_child_relationship, qualifying_relative_relationship, meets_misc_qualifying_relative_requirements_yes)
    @birth_date = birth_date
    @tax_year = tax_year
    @full_time_student_yes = full_time_student_yes
    @permanently_totally_disabled_yes = permanently_totally_disabled_yes
    @ssn_present = ssn_present
    @qualifying_child_relationship = qualifying_child_relationship
    @qualifying_relative_relationship = qualifying_relative_relationship
    @meets_misc_qualifying_relative_requirements_yes = meets_misc_qualifying_relative_requirements_yes

    @age = @tax_year - @birth_date.year
  end

  def born_in_last_6_months?
    @birth_date >= Date.new(@tax_year, 6, 30) && @birth_date <= Date.new(@tax_year, 12, 31)
  end

  def age; @age; end

  def meets_qc_age_condition?
    @permanently_totally_disabled_yes ||
      (@age < 19) ||
      (@full_time_student_yes && @age < 24)
  end

  def disqualified_child_qualified_relative?
    @qualifying_child_relationship && !meets_qc_age_condition?
  end

  def qualifying_relative?
    @meets_misc_qualifying_relative_requirements_yes &&
      @ssn_present &&
      (disqualified_child_qualified_relative? || @qualifying_relative_relationship)
  end
end
