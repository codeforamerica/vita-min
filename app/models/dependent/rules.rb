class Dependent::Rules
  QUALIFYING_RELATIVE_RELATIONSHIPS = %w[parent grandparent aunt uncle]
  QUALIFYING_CHILD_RELATIONSHIPS = %w[daughter son stepchild stepbrother stepsister foster_child grandchild niece nephew half_brother half_sister brother sister]

  def initialize(birth_date, tax_year)
    @birth_date = birth_date
    @tax_year = tax_year
  end

  def born_in_last_6_months?
    @birth_date >= Date.new(@tax_year, 6, 30) && @birth_date <= Date.new(@tax_year, 12, 31)
  end

  def age
    @tax_year - @birth_date.year
  end
end
