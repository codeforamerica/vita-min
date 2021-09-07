class RoutingNumberValidator < ActiveModel::EachValidator
  REGEX = /\A(01|02|03|04|05|06|07|08|09|10|11|12|21|22|23|24|25|26|27|28|29|30|31|32)[0-9]{7}\z/ # Real SSNS cannot have 00 in 4th and 5th position

  def validate_each(record, attr_name, value)
    unless value&.match?(REGEX)
      record.errors.add(attr_name, I18n.t("validators.routing_number"))
    end
  end
end
