class AssetSaleIncomeForm < QuestionsForm
  set_attributes_for :intake, :had_asset_sale_income

  def save
    @intake.update(attributes_for(:intake))
  end
end