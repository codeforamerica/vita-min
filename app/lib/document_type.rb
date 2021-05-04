class DocumentType
  class << self
    def relevant_to?(_intake)
      raise NotImplementedError "Child classes must define when they are relevant to an intake"
    end

    def key
      raise NotImplementedError "A key must be defined in child classes"
    end

    # If you're on a page asking for this document, do we allow you to proceed?
    def blocks_progress?
      false
    end

    # Are we quite sure that, if this document is relevant to an intake, VITA won't interview you until
    # you have this document?
    def needed_if_relevant?
      false
    end

    def provide_doc_help?
      false
    end

    def skip_dont_have?
      false
    end

    def label
      I18n.t("general.document_types.#{key.parameterize(separator: "_")}", default: key)
    end

    def translated_label(locale)
      I18n.t("general.document_types.#{key.parameterize(separator: "_")}", default: key, locale: locale)
    end

    def translated_label_with_description(locale)
      I18n.t("general.document_types.with_descriptions.#{key.parameterize(separator: "_")}", default: key, locale: locale)
    end

    def to_s
      label
    end
  end
end

