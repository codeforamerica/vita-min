Rails.application.reloader.to_prepare do
  module DecimalCleaner
    def cast(value)
      if value.is_a?(String)
        super(value.gsub(/[$,]/, ''))
      else
        super
      end
    end
  end
  ActiveRecord::Type::Decimal.prepend(DecimalCleaner)

  ActiveRecord::Type.register(:money, MoneyType)
end
