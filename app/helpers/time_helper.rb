module TimeHelper
  def date_heading(datetime)
    prefix = datetime.to_date == Date.today ? I18n.t("general.today") + " " : ""
    prefix + default_date_format(datetime)
  end

  def default_date_format(datetime)
    datetime&.to_date&.strftime("%-m/%-d/%Y")
  end

  def formatted_time(datetime)
    datetime.strftime("%l:%M %p #{datetime.zone}").strip
  end

  def long_formatted_datetime(datetime, use_day: true)
    formatted_string = use_day ? "#{datetime.strftime('%a')} " : ""
    formatted_string + "#{default_date_format(datetime)} at #{formatted_time(datetime)}"
  end

  def timestamp(datetime)
    "#{default_date_format(datetime)} #{formatted_time(datetime)}"
  end

  def timezone_select_options
    ActiveSupport::TimeZone.us_zones.map { |tz| [tz.name, tz.tzinfo.name] }
  end

  def displayed_timezone(timezone)
    return nil unless timezone.present?

    entry = timezone_select_options.find { |tz| tz[1] == timezone }
    entry.presence && entry[0]
  end

  def formatted_datetime(datetime)
    return unless datetime

    datetime.strftime("%b %d %-l:%M %p")
  end

  def business_days(datetime)
    return unless datetime

    business_days_ago = Date.parse(datetime.to_s).business_days_until(DateTime.now)
    "#{business_days_ago} business days"
  end

  def formatted_datetime(datetime)
    return unless datetime

    tag.span(datetime.strftime("%b %d %-l:%M %p"))
  end
end
