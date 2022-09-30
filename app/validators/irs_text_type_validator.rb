class IrsTextTypeValidator < ActiveModel::EachValidator
  REGEXP = /\A([!-~£§ÁÉÍÑÓ×ÚÜáéíñóúü] ?)*[!-~£§ÁÉÍÑÓ×ÚÜáéíñóúü]\z/

  def validate_each(record, attr_name, value)
    unless value =~ REGEXP
      record.errors.add(attr_name, I18n.t("errors.messages.invalid"))
    end
  end
end
