require "rails_helper"

RSpec.feature "FAQ" do
  it "links to the most popular questions in each group" do
    visit "/faq"

    click_on I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.question')
    expect(strip_html_tags(page.body)).to include(strip_html_tags(I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.answer_html')))
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