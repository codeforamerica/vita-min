module DocumentTypes
  module PrimaryIdentification
    class Base < DocumentType
      class << self
        def label
          I18n.t("general.document_types.primary_identification.#{to_param}", default: key)
        end

        def translated_label(locale)
          I18n.t("general.document_types.primary_identification.#{to_param}", default: key, locale: locale)
        end
      end
    end
  end
end
