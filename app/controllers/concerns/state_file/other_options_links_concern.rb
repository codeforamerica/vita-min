module StateFile
  module OtherOptionsLinksConcern
    # This concern can be used by any controller that needs to link to the
    # VITA Google Form on the offboarding pages or the other state filing options on the FAQ
    extend ActiveSupport::Concern

    included do
      before_action :load_links, only: :edit
    end

    def load_links
      @vita_link = vita_link
      @faq_other_options_link = faq_state_filing_options_link
    end

    def vita_link
      case current_state_code
      when 'ny'
        'https://airtable.com/appQS3abRZGjT8wII/pagtpLaX0wokBqnuA/form'
      when 'az'
        'https://airtable.com/appnKuyQXMMCPSvVw/pag0hcyC6juDxamHo/form'
      end
    end

    def faq_state_filing_options_link
      product_type = FaqCategory.state_to_product_type(current_state_code)
      if FaqCategory.where(slug: "other_state_filing_options", product_type: product_type).present?
        state_faq_section_path(section_key: "other_state_filing_options", us_state: current_state_code)
      else
        state_faq_path
      end
    end
  end
end