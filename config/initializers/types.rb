Rails.application.reloader.to_prepare do
  ActiveRecord::Type.register(:money, MoneyType)
end
