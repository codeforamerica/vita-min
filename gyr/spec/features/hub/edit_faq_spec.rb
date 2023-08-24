require "rails_helper"

RSpec.feature "Updating FAQ" do
  let(:user) { create :admin_user }
  let!(:faq_category) { create(:faq_category, name_en: 'Animal Questions')}
  let!(:faq_item) do
    create(:faq_item, faq_category: faq_category, question_en: 'How much wood could a woodchuck chuck?', answer_en: 'Approximately <b>10</b> bushels')
  end

  before { login_as user }

  it "can edit existing questions" do
    visit "/hub/faq"

    expect(page).to have_content(faq_category.name_en)
    expect(page).to have_content(faq_item.question_en)

    find_link(faq_item.question_en).ancestor('tr').find_link('Edit').click
    expect(find('[name=hub_faq_item_form\[answer_en\]]', visible: false).value).to eq(faq_item.answer_en.to_trix_html)
  end
end