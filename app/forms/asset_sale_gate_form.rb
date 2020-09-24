class AssetSaleGateForm < QuestionsForm
  set_attributes_for :intake, :sold_assets

  def save
    @intake.update(attributes_for(:intake))
  end
end