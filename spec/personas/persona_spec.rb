require "rails_helper"

describe "personas" do
  context "2023" do
    let(:tax_year) { 2023 }

    context "az" do
      let(:state_code) { :az }

      context "johnny" do
        let(:persona_name) { "johnny" }
        let(:submission_id) { "1234562024165nly30yy" }
        it_behaves_like :persona
      end

      context "leslie" do
        let(:persona_name) { "leslie" }
        let(:submission_id) { "12345620241830jo1lnk" }
        it_behaves_like :persona
      end

      context "martha" do
        let(:persona_name) { "martha" }
        let(:submission_id) { "1234562024183bsoh6yt" }
        it_behaves_like :persona
      end
    end

    context "ny" do
      let(:state_code) { :ny }

      context "javier" do
        let(:persona_name) { "414h_test" }
        let(:submission_id) { "1234562024177c2kg88t" }
        it_behaves_like :persona
      end
    end

  end
end
