module DateHelper
  def date_heading(datetime)
    prefix = datetime.to_date == Date.today ? I18n.t("general.today") + " " : ""
    prefix + datetime.to_date.strftime("%m/%d/%Y")
  end
end