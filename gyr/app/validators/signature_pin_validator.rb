class SignaturePinValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    return unless value.present?

    unless /\A\d{5}\z/.match?(value.to_s)
      record.errors.add(attr_name, I18n.t("validators.signature_pin"))
    end

    if value.to_s == "00000"
      record.errors.add(attr_name, I18n.t("validators.signature_pin_zeros"))
    end
  end
end