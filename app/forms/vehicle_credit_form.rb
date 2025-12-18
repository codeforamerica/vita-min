class VehicleCreditForm < QuestionsForm
  set_attributes_for :intake, :new_vehicle_purchased

  def save
    @intake.update(attributes_for(:intake))
  end
end