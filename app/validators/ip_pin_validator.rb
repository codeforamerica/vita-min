class IpPinValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    return unless value.present?

    unless /\A\d{6}\z/.match?(value.to_s)
      record.errors.add(attr_name, I18n.t("validators.ip_pin"))
    end
  end
end
