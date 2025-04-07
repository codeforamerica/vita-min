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
      I18n.locale == :en ? StateFile::StateInformationService.vita_link_en(current_state_code) : StateFile::StateInformationService.vita_link_es(current_state_code)
    end

    def faq_state_filing_options_link
      case current_state_code
      when 'az'
        state_faq_section_path(us_state: :az, section_key: "other_state_filing_options")
      when 'nc'
        state_faq_section_path(us_state: :nc, section_key: "what_are_my_other_state_filing_options_this_year")
      when 'id'
        state_faq_section_path(us_state: :id, section_key: "what_are_my_other_state_filing_options_this_year_53")
      when 'md'
        state_faq_section_path(us_state: :md, section_key: "what_are_my_other_state_filing_options_this_year_46")
      when 'nj'
        state_faq_section_path(us_state: :nj, section_key: "other_filing_options")
      else
        state_faq_path(us_state: current_state_code)
      end
    end
  end
end