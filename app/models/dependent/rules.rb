class Dependent::Rules
  def initialize(birth_date, tax_year, full_time_student_yes, permanently_totally_disabled_yes, ssn_present, qualifying_child_relationship, qualifying_relative_relationship, meets_misc_qualifying_relative_requirements_yes, meets_qc_residence_condition_generic, meets_qc_claimant_condition, meets_qc_misc_conditions)
    @birth_date = birth_date
    @tax_year = tax_year
    @full_time_student_yes = full_time_student_yes
    @permanently_totally_disabled_yes = permanently_totally_disabled_yes
    @ssn_present = ssn_present
    @qualifying_child_relationship = qualifying_child_relationship
    @qualifying_relative_relationship = qualifying_relative_relationship
    @meets_misc_qualifying_relative_requirements_yes = meets_misc_qualifying_relative_requirements_yes
    @meets_qc_residence_condition_generic = meets_qc_residence_condition_generic
    @meets_qc_claimant_condition = meets_qc_claimant_condition
    @meets_qc_misc_conditions = meets_qc_misc_conditions

    @age = @tax_year - @birth_date.year
  end

  def born_in_final_6_months?
    @birth_date >= Date.new(@tax_year, 6, 30) && @birth_date <= Date.new(@tax_year, 12, 31)
  end

  def age; @age; end

  def meets_qc_age_condition?
    @age >= 0 && (
      @permanently_totally_disabled_yes ||
        (@age < 19) ||
        (@full_time_student_yes && @age < 24)
    )
  end

  def disqualified_child_qualified_relative?
    @age >= 0 && (
      @qualifying_child_relationship && !meets_qc_age_condition?
    )
  end

  def qualifying_relative?
    @meets_misc_qualifying_relative_requirements_yes &&
      @ssn_present &&
      (disqualified_child_qualified_relative? || @qualifying_relative_relationship)
  end

  def meets_qc_residence_condition?
    @meets_qc_residence_condition_generic || born_in_final_6_months?
  end

  def qualifying_child?
    @qualifying_child_relationship &&
      @ssn_present &&
      @meets_qc_claimant_condition &&
      @meets_qc_misc_conditions &&
      meets_qc_age_condition? &&
      meets_qc_residence_condition?
  end
end
