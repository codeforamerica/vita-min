class MoneyType < ActiveRecord::Type::Integer
  def cast(value)
    if value.kind_of?(String) && value.include?('$')
      super(value.gsub(/\$/, ''))
    else
      super
    end
  end
end
