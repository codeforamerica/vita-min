module SubmissionBuilder
  module FormattingMethods
    extend ActiveSupport::Concern

    def trim(string, length)
      string.first(length)
    end

    def datetime_type(datetime)
      return nil unless datetime.present?

      datetime.strftime("%FT%T%:z")
    end

    def date_type(date)
      return nil unless date.present?

      date.strftime("%F")
    end

    def person_name_type(string)
      name = string.gsub(" ", "<")
      trim(name, 35)
    end

    # Limit to max 4 chars uppercased
    def person_name_control_type(string)
      return "" unless string.present?

      string.upcase.first(4)
    end

    # phone number without country code or formatting
    # results in 10 digit number for transmitting to the IRS
    def phone_type(string)
      Phonelib.parse(string, "US").national(false)
    end
  end
end