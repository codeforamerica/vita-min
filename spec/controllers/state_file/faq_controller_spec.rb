require "rails_helper"

RSpec.describe StateFile::FaqController do
  render_views

  describe "#index" do
    let(:current_year) { Rails.configuration.state_file_start_of_open_intake.year }
    let(:tax_year) { current_year - 1 }
    before do
      allow(Rails.configuration).to receive(:statefile_current_tax_year).and_return(tax_year)
    end

    it "renders the page" do
      get :index, params: { us_state: "us" }

      expect(response).to be_ok
    end
  end

  describe "#show" do
    let(:section_key) { "sluggy_slug" }
    let!(:faq_category) { create :faq_category, slug: section_key, product_type: "state_file_az" }

    it "shows the description" do
      get :show, params: { section_key: section_key, us_state: "az" }

      expect(response.body).to have_text faq_category.description_en
    end
  end
end
