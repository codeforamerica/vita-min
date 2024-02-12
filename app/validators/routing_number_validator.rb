class RoutingNumberValidator < ActiveModel::EachValidator
  REGEX = /\A(01|02|03|04|05|06|07|08|09|10|11|12|21|22|23|24|25|26|27|28|29|30|31|32)[0-9]{7}\z/

  def validate_each(record, attr_name, value)
    unless value&.match?(REGEX) && self.class.passes_checksum(value)
      record.errors.add(attr_name, I18n.t("validators.routing_number"))
    end
  end

  def self.passes_checksum(value)
    digits = value.split("").map(&:to_i)
    (3 * (digits[0] + digits[3] + digits[6]) + 7 * (digits[1] + digits[4] + digits[7]) + digits[2] + digits[5] + digits[8]) % 10 == 0
  end
end
