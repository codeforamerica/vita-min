module TimeHelper
  def date_heading(datetime)
    prefix = datetime.to_date == Date.today ? I18n.t("general.today") + " " : ""
    prefix + datetime.to_date.strftime("%m/%d/%Y")
  end

  def formatted_time(datetime)
    datetime.strftime("%l:%M %p #{datetime.zone}").strip
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
    datetime.strftime("%b %d %-l:%M %p")
  end
end
