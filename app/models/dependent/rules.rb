class Dependent::Rules
  QUALIFYING_RELATIVE_RELATIONSHIPS = [
    "parent",
    "grandparent",
    "aunt",
    "uncle"
  ]
  QUALIFYING_CHILD_RELATIONSHIPS = [
    "daughter",
    "son",
    "stepchild",
    "stepbrother",
    "stepsister",
    "foster_child",
    "grandchild",
    "niece",
    "nephew",
    "half_brother",
    "half_sister",
    "brother",
    "sister"
  ]

  def initialize(birth_date, tax_year)
    @birth_date = birth_date
    @tax_year = tax_year
  end

  def born_in_last_6_months?
    @birth_date >= Date.new(@tax_year, 6, 30) && @birth_date <= Date.new(@tax_year, 12, 31)
  end
end
