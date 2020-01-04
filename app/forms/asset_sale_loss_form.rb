class AssetSaleLossForm < QuestionsForm
  set_attributes_for :intake, :reported_asset_sale_loss

  def save
    @intake.update(attributes_for(:intake))
  end
end