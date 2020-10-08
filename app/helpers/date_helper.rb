module DateHelper
  def date_heading(datetime)
    prefix = datetime.to_date == Date.today ? I18n.t("general.today") + " " : ""
    prefix + datetime.to_date.strftime("%m/%d/%Y")
  end

  def formatted_time(datetime)
    datetime.strftime("%l:%M %p #{datetime.zone}").strip
  end
end
