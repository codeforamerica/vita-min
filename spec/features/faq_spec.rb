require "rails_helper"

RSpec.feature "FAQ" do
  it "links to the most popular questions in each group" do
    visit "/faq"

    click_on I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.question')
    expect(page).to have_content(strip_html_tags(I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.answer_html')))
  end

  it "has a link within each section to show all questions in that section" do
    pending "later!!"
    visit "/faq"

    click_on I18n.t('views.public_pages.faq.question_groups.stimulus.title')
    click_on I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.question')
    expect(page).to have_content(strip_html_tags(I18n.t('views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.answer_html')))
  end
end