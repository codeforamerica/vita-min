module StateFile
  module OtherOptionsLinksConcern
    # This concern can be used by any controller that needs to link to the
    # VITA Google Form on the offboarding pages or the other state filing options on the FAQ
    extend ActiveSupport::Concern

    def vita_link
      case params[:us_state]
      when 'ny'
        'https://airtable.com/appQS3abRZGjT8wII/pagtpLaX0wokBqnuA/form'
      when 'az'
        'https://airtable.com/appnKuyQXMMCPSvVw/pag0hcyC6juDxamHo/form'
      end
    end

    def faq_state_filing_options_link
      product_type = FaqCategory.state_to_product_type(params[:us_state])
      if FaqCategory.where(slug: "other_state_filing_options", product_type: product_type).present?
        state_faq_section_path(section_key: "other_state_filing_options", us_state: params[:us_state])
      else
        state_faq_path
      end
    end
  end
end