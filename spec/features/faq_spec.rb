require "rails_helper"

RSpec.feature "FAQ" do
  it "links to the most popular questions in each group" do
    visit "/faq"

    click_on I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.question')
    expect(strip_html_tags(page.body)).to include(strip_html_tags(I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.answer_html')))
  end

  it "records survey answers" do
    visit "/faq"

    click_on I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.question')
    click_on I18n.t('views.questions.successfully_submitted.satisfaction_face.positive')

    survey = FaqSurvey.last
    expect(survey.question_key).to eq('how_many_stimulus_payments_were_there')
    expect(survey.visitor_id).to be_present
    expect(survey).to be_answer_positive

    click_on I18n.t('views.questions.successfully_submitted.satisfaction_face.negative')
    expect(survey.reload).to be_answer_negative
    expect(FaqSurvey.count).to eq(1)
  end

  it "has a link within each section to show all questions in that section" do
    visit "/faq"

    within '.faq-section-stimulus' do
      click_on "View all questions"
    end

    click_on I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.question')
    expect(strip_html_tags(page.body)).to include(strip_html_tags(I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.answer_html')))

    # go back to index
    within ".breadcrumb" do
      click_on I18n.t('views.public_pages.faq.question_groups.stimulus.title')
    end
    expect(page).to have_selector("h1", text: I18n.t('views.public_pages.faq.question_groups.stimulus.title'))
  end
end
