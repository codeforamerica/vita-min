class PositiveMoneyFieldValidator < ActiveModel::EachValidator
  def validate_each(form, attribute, value)
    if value.blank?
      form.errors.add(attribute, form.payment_msg)
      return
    end

    unless value.to_s.match?(/\A-?\d+(?:\.\d+)?\z/)
      form.errors.add(attribute, I18n.t("validators.not_a_number"))
      return
    end

    form.errors.add(attribute, form.payment_msg) if value.to_d <= 0
  end
end
