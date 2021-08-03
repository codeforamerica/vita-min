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
      name_line = formatted_first_name(primary_first)
      name_line << " #{primary_middle.upcase}" if primary_middle

      if spouse_last == primary_last # spouse with same last name
        name_line << " & #{formatted_first_name(spouse_first)}"
        name_line << " #{spouse_middle.upcase}" if spouse_middle
      end

      if spouse_last && spouse_last != primary_last # spouse with different last name
        name_line << "<#{formatted_last_name(primary_last)}"
        name_line << "<& #{formatted_first_name(spouse_first)}"
        name_line << " #{spouse_middle.upcase}" if spouse_middle
        name_line << " #{formatted_last_name(spouse_last)}"
        return name_line
      end

      # single or spouse with same last name
      name_line << "<#{formatted_last_name(primary_last)}"

      # add in support for formatting JR/2nd/II
      # add in support for 35+ char names
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
      I18n.transliterate(name).upcase.gsub(/[^A-Z]/, '')
    end

    def formatted_last_name(name)
      I18n.transliterate(name).upcase.gsub(/[^A-Z\-]/, '')
    end
  end
end