class SchoolSuppliesForm < QuestionsForm
  set_attributes_for :intake, :paid_school_supplies

  def save
    @intake.update(attributes_for(:intake))
  end
end