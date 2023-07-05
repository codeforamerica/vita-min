require "rails_helper"

RSpec.feature "FAQ" do
  let!(:faq_category) { create(:faq_category, name_en: 'Animal Questions')}
  let!(:faq_item) do
    create(:faq_item, faq_category: faq_category, question_en: 'How much wood could a woodchuck chuck?', answer_en: 'Approximately <b>10</b> bushels')
  end

  it "links to the most popular questions in each group" do
    visit "/faq"

    click_on faq_item.question_en
    expect(strip_html_tags(page.body)).to include(faq_item.answer_en.to_plain_text)
  end

  it "records survey answers" do
    visit "/faq"

    click_on faq_item.question_en
    click_on I18n.t('views.questions.successfully_submitted.satisfaction_face.positive')

    survey = FaqSurvey.last
    expect(survey.question_key).to eq(faq_item.slug)
    expect(survey.visitor_id).to be_present
    expect(survey).to be_answer_positive

    click_on I18n.t('views.questions.successfully_submitted.satisfaction_face.negative')
    expect(survey.reload).to be_answer_negative
    expect(FaqSurvey.count).to eq(1)
  end

  it "has a link within each section to show all questions in that section" do
    visit "/faq"

    within ".faq-section-#{faq_category.slug.dasherize}" do
      click_on "View all questions"
    end

    click_on faq_item.question_en
    expect(strip_html_tags(page.body)).to include(faq_item.answer_en.to_plain_text)

    # go back to index
    within ".breadcrumb" do
      click_on faq_category.name_en
    end
    expect(page).to have_selector("h1", text: faq_category.name_en)
  end
end
