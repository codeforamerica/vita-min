class PositiveMoneyFieldValidator < ActiveModel::EachValidator
  def validate_each(form, attribute, value)
    if value.blank?
      form.errors.add(attribute, form.error_msg_if_blank_or_zero)
      return
    end

    unless value.to_s.match?(/\A-?\d+(?:\.\d+)?\z/)
      form.errors.add(attribute, I18n.t("validators.not_a_number"))
      return
    end

    form.errors.add(attribute, form.error_msg_if_blank_or_zero) if value.to_d <= 0
  end
end
