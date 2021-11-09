class Dependent::Rules
  def initialize(birth_date, tax_year, full_time_student_yes, permanently_totally_disabled_yes)
    @birth_date = birth_date
    @tax_year = tax_year
    @full_time_student_yes = full_time_student_yes
    @permanently_totally_disabled_yes = permanently_totally_disabled_yes

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
end
