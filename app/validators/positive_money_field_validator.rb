class PositiveMoneyFieldValidator < ActiveModel::EachValidator
  def validate_each(form, attribute, value)
    error_msg = form.respond_to?(:error_msg_if_blank_or_zero) ? form.error_msg_if_blank_or_zero : I18n.t('errors.attributes.money_field')

    if value.blank?
      form.errors.add(attribute, error_msg)
      return
    end

    unless value.to_s.match?(/\A-?\d+(?:\.\d+)?\z/)
      form.errors.add(attribute, I18n.t("validators.not_a_number"))
      return
    end

    form.errors.add(attribute, error_msg) if value.to_d <= 0
  end
end
