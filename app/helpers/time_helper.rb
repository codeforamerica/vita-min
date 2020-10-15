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

  def formatted_datetime(datetime)
    datetime.strftime("%b %-d, %Y %l:%M %p %Z").strip
  end
end
