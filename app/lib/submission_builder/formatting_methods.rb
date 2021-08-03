module SubmissionBuilder
  module FormattingMethods
    extend ActiveSupport::Concern

    def trim(string, length)
      string.first(length)
    end

    def datetime_type(datetime)
      datetime.strftime("%FT%T%:z")
    end

    def date_type(date)
      date.strftime("%F")
    end

    def name_line_1_type(primary_first, primary_middle, primary_last, spouse_first, spouse_middle, spouse_last)
      name_line = build_name_line_1(primary_first, primary_middle, primary_last, spouse_first, spouse_middle, spouse_last)

      # if the line > 35 characters then truncate according to the guidelines on page 189 of https://www.irs.gov/pub/irs-pdf/p4164.pdf
      if name_line.size > 35 && spouse_last.present? # shorten spouse last
        name_line = build_name_line_1(primary_first, primary_middle, primary_last, spouse_first, spouse_middle, spouse_last.first)
      end
      if name_line.size > 35 # shorten primary last
        name_line = build_name_line_1(primary_first, primary_middle, primary_last.first, spouse_first, spouse_middle, spouse_last&.first)
      end
      if name_line.size > 35 && spouse_middle.present? # remove spouse middle
        name_line = build_name_line_1(primary_first, primary_middle, primary_last.first, spouse_first, nil, spouse_last.first)
      end
      if name_line.size > 35 && primary_middle.present? # remove primary middle
        name_line = build_name_line_1(primary_first, nil, primary_last.first, spouse_first, nil, spouse_last&.first)
      end
      if name_line.size > 35 && spouse_first.present? # shorten spouse first
        name_line = build_name_line_1(primary_first, nil, primary_last.first, spouse_first.first, nil, spouse_last.first)
      end
      if name_line.size > 35 # shorten primary first
        name_line = build_name_line_1(primary_first.first, nil, primary_last.first, spouse_first&.first, nil, spouse_last&.first)
      end

      name_line
    end

    # The IRS has very particular guidelines for what this line should look like and they are
    # outlined on page 189 of https://www.irs.gov/pub/irs-pdf/p4164.pdf
    def build_name_line_1(primary_first, primary_middle, primary_last, spouse_first, spouse_middle, spouse_last)
      # add in support for formatting JR/2nd/II
      name_line = formatted_first_name(primary_first)
      name_line << " #{primary_middle.upcase}" if primary_middle

      if spouse_last == primary_last # spouse with same last name
        name_line << " & #{formatted_first_name(spouse_first)}"
        name_line << " #{spouse_middle.upcase}" if spouse_middle
      elsif spouse_last && spouse_last != primary_last # spouse with different last name
        name_line << "<#{formatted_last_name(primary_last)}"
        name_line << "<& #{formatted_first_name(spouse_first)}"
        name_line << " #{spouse_middle.upcase}" if spouse_middle
        name_line << " #{formatted_last_name(spouse_last)}"
        return name_line
      end

      # single or spouse with same last name
      name_line << "<#{formatted_last_name(primary_last)}"
    end

    # Limit to max 4 chars uppercased
    def person_name_control_type(string)
      return "" unless string.present?

      string.first(4).upcase
    end

    # phone number without country code or formatting
    # results in 10 digit number for transmitting to the IRS
    def phone_type(string)
      Phonelib.parse(string, "US").national(false)
    end

    private

    def formatted_first_name(name)
      # removes accented characters and any special characters
      I18n.transliterate(name).upcase.gsub(/[^A-Z]/, '')
    end

    def formatted_last_name(name)
      # removes accented characters and any special characters, except hyphens
      I18n.transliterate(name).upcase.gsub(/[^A-Z\-]/, '')
    end
  end
end