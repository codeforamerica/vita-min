module SubmissionBuilder
  module FormattingMethods
    extend ActiveSupport::Concern

    def trim(string, length)
      string.squish.first(length)&.strip
    end

    def sanitize_for_xml(string, length = nil)
      sanitized_string = string&.gsub(/\s+/, ' ')
      if length
        sanitized_string = sanitized_string&.first(length)
      end
      sanitized_string&.strip
    end

    def sanitize_zipcode(zipcode_str)
      sanitized_zipcode = sanitize_for_xml(zipcode_str)
      sanitized_zipcode.gsub("-", "")
    end

    def sanitize_middle_initial(middle_initial)
      return if middle_initial.blank?

      sanitized_middle_initial = sanitize_for_xml(middle_initial)
      sanitized_middle_initial = sanitized_middle_initial.tr('^A-Za-z', '')
      sanitized_middle_initial&.first(1)
    end

    def datetime_type(datetime)
      return nil unless datetime.present?

      datetime.strftime("%FT%T%:z")
    end

    def date_type(date)
      return nil unless date.present?

      date.strftime("%F")
    end

    def date_type_for_timezone(date)
      return nil unless date.present?
      timezone = StateFile::StateInformationService.timezone(@submission.data_source.state_code)
      date.in_time_zone(timezone)
    end

    def person_name_type(name, length: 20)
      return "" unless name.present?

      trim(I18n.transliterate(name).strip.gsub(/[^A-Za-z\-\s]/, ''), length)
    end

    def name_line_1_type(primary_first, primary_middle, primary_last, primary_suffix, spouse_first = nil, spouse_middle = nil, spouse_last = nil)
      name_line = build_name_line_1(primary_first, primary_middle, primary_last, primary_suffix, spouse_first, spouse_middle, spouse_last)

      # if the line > 35 characters then truncate according to the guidelines on page 189 of https://www.irs.gov/pub/irs-pdf/p4164.pdf
      if name_line.size > 35 && spouse_last.present? # shorten spouse last
        name_line = build_name_line_1(primary_first, primary_middle, primary_last, primary_suffix, spouse_first, spouse_middle, spouse_last.first)
      end
      if name_line.size > 35 # shorten primary last
        name_line = build_name_line_1(primary_first, primary_middle, primary_last.first, primary_suffix, spouse_first, spouse_middle, spouse_last&.first)
      end
      if name_line.size > 35 && spouse_middle.present? # remove spouse middle
        name_line = build_name_line_1(primary_first, primary_middle, primary_last.first, primary_suffix, spouse_first, nil, spouse_last.first)
      end
      if name_line.size > 35 && primary_middle.present? # remove primary middle
        name_line = build_name_line_1(primary_first, nil, primary_last.first, primary_suffix, spouse_first, nil, spouse_last&.first)
      end
      if name_line.size > 35 && spouse_first.present? # shorten spouse first
        name_line = build_name_line_1(primary_first, nil, primary_last.first, primary_suffix, spouse_first.first, nil, spouse_last.first)
      end
      if name_line.size > 35 # shorten primary first
        name_line = build_name_line_1(primary_first.first, nil, primary_last.first, primary_suffix, spouse_first&.first, nil, spouse_last&.first)
      end

      name_line
    end

    # The IRS has very particular guidelines for what this line should look like and they are
    # outlined on page 189 of https://www.irs.gov/pub/irs-pdf/p4164.pdf
    def build_name_line_1(primary_first, primary_middle, primary_last, primary_suffix, spouse_first, spouse_middle, spouse_last)
      name_line = formatted_first_or_middle_name(primary_first)
      name_line << " #{formatted_first_or_middle_name(primary_middle.upcase)}" if primary_middle

      if spouse_last == primary_last # spouse with same last name
        name_line << " & #{formatted_first_or_middle_name(spouse_first)}"
        name_line << " #{formatted_first_or_middle_name(spouse_middle.upcase)}" if spouse_middle
      elsif spouse_last && spouse_last != primary_last # spouse with different last name
        name_line << "<#{formatted_last_name(primary_last)}"
        name_line << if primary_suffix
                       "<#{primary_suffix.upcase} & #{formatted_first_or_middle_name(spouse_first)}"
                     else
                       "<& #{formatted_first_or_middle_name(spouse_first)}"
                     end
        name_line << " #{formatted_first_or_middle_name(spouse_middle.upcase)}" if spouse_middle
        name_line << " #{formatted_last_name(spouse_last)}"
        return name_line
      end

      # single or spouse with same last name
      name_line << "<#{formatted_last_name(primary_last)}"
      name_line << "<#{primary_suffix.upcase}" if primary_suffix.present?
      name_line
    end

    # Limit to max 4 chars uppercased with special characters and spaces removed
    def name_control_type(string)
      return "" unless string.present?

      formatted_last_name(string).delete(" ").first(4)
    end

    def account_number_type(string)
      return "" unless string.present?

      string.delete(" ")
    end

    # phone number without country code or formatting
    # results in 10 digit number for transmitting to the IRS
    def phone_type(string)
      phony_normalized = Phony.normalize(string, cc: '1')
      Phony.format(phony_normalized, format: :national, parentheses: false, spaces: '', local_spaces: '').to_s
    end

    # Timezones like '-60' need to be padded to '-060' to validate schema
    # These timezones are all a little suspicious, but it's better to handle
    # their suspiciousness somewhere else rather than crash on bundle
    def time_zone_offset_type(string)
      if (match = string.match(/\A([+-])([0-9]{1,2})\z/))
        "#{match[1]}#{"%03d" % match[2]}"
      else
        string
      end
    end

    private

    def formatted_first_or_middle_name(name)
      # removes accented characters and any special characters, except space
      I18n.transliterate(name).strip.upcase.gsub(/[^A-Z\s]/, '')
    end

    def formatted_last_name(name)
      # removes accented characters and any special characters, except space and hyphens
      I18n.transliterate(name).strip.upcase.gsub(/[^A-Z\-\s]/, '')
    end
  end
end
