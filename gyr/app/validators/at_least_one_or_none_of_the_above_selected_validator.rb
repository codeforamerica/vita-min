class AtLeastOneOrNoneOfTheAboveSelectedValidator < ActiveModel::EachValidator
  def validate_each(model, attr_name, value)
    unless model.respond_to?(:at_least_one_selected)
      raise "Form must implement at_least_one_selected"
    end

    at_least_one = model.at_least_one_selected

    if at_least_one && value == "yes"
      model.errors.add(attr_name, I18n.t("general.please_select_at_least_one_option"))
      return
    end

    unless at_least_one || value == "yes"
      model.errors.add(attr_name, I18n.t("general.please_select_at_least_one_option"))
      return
    end
  end
end
