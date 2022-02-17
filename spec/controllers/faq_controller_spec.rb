require "rails_helper"

RSpec.describe FaqController do
  render_views

  describe "#index" do
    it "renders the faq section headers" do
      get :index

      expect(response.body).to have_text I18n.t("views.public_pages.faq.question_groups.stimulus.title")
      expect(response.body).to have_text I18n.t("views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.question")
    end
  end

  describe "#section_index" do
    it "renders the section header and questions" do
      get :section_index, params: { section_key: "stimulus" }

      expect(response.body).to have_text I18n.t("views.public_pages.faq.question_groups.stimulus.title")
      expect(response.body).to have_text I18n.t("views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.question")
    end

    it "renders 404 for sections that do not exist" do
      expect do
        get :section_index, params: { section_key: "stimuli" }
      end.to raise_error(ActionController::RoutingError)
    end
  end

  describe "#show" do
    it "renders the question and answer" do
      get :show, params: { section_key: "stimulus", question_key: "how-many-stimulus-payments-were-there" }

      expect(response.body).to have_text I18n.t("views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.question")
      expect(response.body).to have_text ActionController::Base.helpers.strip_tags(I18n.t("views.public_pages.faq.question_groups.stimulus.how_many_stimulus_payments_were_there.answer_html"))
    end

    it "renders 404 for questions that do not exist" do
      expect do
        get :show, params: { section_key: "stimuli", question_key: "how-many-toadstools-were-there" }
      end.to raise_error(ActionController::RoutingError)
    end
  end
end
