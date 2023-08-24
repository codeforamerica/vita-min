class EnergyEfficientPurchasesForm < QuestionsForm
  set_attributes_for :intake, :bought_energy_efficient_items

  def save
    @intake.update(attributes_for(:intake))
  end
end