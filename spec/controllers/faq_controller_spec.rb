require "rails_helper"

RSpec.describe FaqController do
  render_views

  let!(:faq_category) { create(:faq_category, name_en: 'Animal Questions', position: 2)}
  let!(:faq_item) do
    create(:faq_item, faq_category: faq_category, question_en: 'How much wood could a woodchuck chuck?', position: 2)
  end

  describe "#index" do
    let!(:first_category) { create(:faq_category, name_en: 'Vegetable Questions', position: 1)}
    let!(:last_category) { create(:faq_category, name_en: 'Mineral Questions', position: 3)}

    let!(:first_item) do
      create(:faq_item, faq_category: faq_category, question_en: 'Why did the chicken cross the road?', position: 1)
    end
    let!(:last_item) do
      create(:faq_item, faq_category: faq_category, question_en: "Who's moose is this?", position: 3)
    end

    it "renders the faq section headers in order based on the position column" do
      get :index

      expect(response.body).to have_text faq_category.name_en
      expect(response.body).to have_text faq_item.question_en

      expect(assigns(:faq_categories).to_a).to eq([first_category, faq_category, last_category])
      expect(assigns(:faq_categories)[1].faq_items).to eq([first_item, faq_item, last_item])
    end
  end

  describe "#section_index" do
    it "renders the section header and questions" do
      get :section_index, params: { section_key: faq_category.slug }

      expect(response.body).to have_text faq_category.name_en
      expect(response.body).to have_text faq_item.question_en
    end

    it "renders 404 for sections that do not exist" do
      expect do
        get :section_index, params: { section_key: "stimuli" }
      end.to raise_error(ActionController::RoutingError)
    end
  end

  describe "#show" do
    it "renders the question and answer" do
      get :show, params: { section_key: faq_category.slug, question_key: faq_item.slug }

      expect(response.body).to have_text faq_item.question_en
      expect(response.body).to have_text faq_item.answer_en.to_plain_text
    end

    it "renders 404 for questions that do not exist" do
      expect do
        get :show, params: { section_key: "stimuli", question_key: "how-many-toadstools-were-there" }
      end.to raise_error(ActionController::RoutingError)
    end

    it "renders 404 for null byte params" do
      expect do
        get :show, params: { section_key: "stimuli", question_key: "\x00" }
      end.to raise_error(ActionController::RoutingError)
    end
  end

  describe "QUESTIONS" do
    it "has everything that is in the yml, but in the right order" do
      I18n.backend.send(:lookup, :en, "views.public_pages.faq.question_groups").keys.each do |question_group_title|
        question_keys = I18n.backend.send(:lookup, :en, "views.public_pages.faq.question_groups.#{question_group_title}").keys.excluding(:title)
        expect(FaqController::QUESTIONS[question_group_title]).to match_array(question_keys)
      end
    end
  end
end