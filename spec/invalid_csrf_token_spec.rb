require "rails_helper"

feature "Invalid CSRF token redirect" do
  include MockDogapi

  before do
    # Rails turns off CSRF checks in test by default, turn them back on for just this test
    allow_any_instance_of(ApplicationController).to receive(:protect_against_forgery?).and_return(true)

    enable_datadog_and_stub_emit_point
  end

  let!(:faq_item) { create(:faq_item, question_en: 'How do I get the stimulus payments?') }

  it "re-renders the form the user was on, with an error message" do
    visit "/faq"

    click_on faq_item.question(I18n.locale)
    clear_cookies

    expect do
      click_on I18n.t('views.questions.successfully_submitted.satisfaction_face.positive')
    end.not_to change { FaqSurvey.count }

    expect(page).to have_content(I18n.t('general.authenticity_token_invalid'))

    expect(@emit_point_params).to eq([
      ["vita-min.dogapi.rails.invalid_authenticity_token", 1, {:tags=>["env:test"], :type=>"count"}]
    ])
  end
end
