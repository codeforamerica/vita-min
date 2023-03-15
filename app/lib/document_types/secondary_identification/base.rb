module DocumentTypes
  module SecondaryIdentification
    class Base < DocumentType
      class << self
        def translated_label(locale)
          I18n.t("general.document_types.secondary_identification.#{to_param}", default: key, locale: locale)
        end
      end
    end
  end
end
