module NavigationHelpers
  def fill_out_personal_information(name: "Betty Banana", zip_code:, birth_date: Date.parse("1983-10-12"), phone_number: "415-888-0088")
    expect(page).to have_text I18n.t('views.questions.personal_info.title')
    fill_in I18n.t('views.questions.personal_info.preferred_name'), with: name
    select birth_date.strftime("%B"), from: "personal_info_form[birth_date_month]"
    select birth_date.day, from: "personal_info_form[birth_date_day]"
    select birth_date.year, from: "personal_info_form[birth_date_year]"
    fill_in I18n.t('views.questions.personal_info.zip_code'), with: zip_code
    fill_in I18n.t('views.questions.personal_info.phone_number'), with: phone_number
    fill_in I18n.t('views.questions.personal_info.phone_number_confirmation'), with: phone_number
    click_on I18n.t('general.continue')
  end
end