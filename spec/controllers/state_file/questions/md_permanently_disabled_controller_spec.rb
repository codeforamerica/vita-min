require "rails_helper"

RSpec.describe StateFile::Questions::MdPermanentlyDisabledController do
  let(:intake) { create :state_file_md_intake }

  before do
    sign_in intake
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
  end

  describe "#show?" do
    context "when they have no 1099Rs in their DF XML" do
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when they have at least one 1099R in their DF XML" do
      let!(:first_1099r) { create :state_file1099_r, intake: intake }

      it "shows" do
        expect(described_class.show?(intake)).to eq true
      end
    end
  end

  describe "#edit" do
    render_views

    it "renders the view" do
      get :edit
      expect(response).to be_successful
    end

    context "mfj vs not-mfj" do
      context "mfj filers" do
        let(:intake) { create :state_file_md_intake, :with_spouse }

        it "shows the mfj version of the question" do
          get :edit

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("#state_file_md_permanently_disabled_form_mfj_disability_primary")).to be_present
          expect(html.at_css("#state_file_md_permanently_disabled_form_primary_disabled_yes")).not_to be_present
        end
      end

      context "other filing status" do
        let(:intake) { create :state_file_md_intake, filing_status: "head_of_household" }

        it "shows the single version of the question" do
          get :edit

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("#state_file_md_permanently_disabled_form_mfj_disability_primary")).not_to be_present
          expect(html.at_css("#state_file_md_permanently_disabled_form_primary_disabled_yes")).to be_present
        end
      end
    end

    context "proof followup" do
      context "mfj filers" do
        let(:intake) { create :state_file_md_intake, :with_spouse }

        it "has all followups when spouse is not senior" do
          intake.update(primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 66), 1, 1))
          intake.update(spouse_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1))
          get :edit

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("input[data-follow-up='#spouse-disability-proof']")).to be_present
          expect(html.at_css("input[data-follow-up='#primary-disability-proof']")).to be_present
          expect(html.at_css("input[data-follow-up='#both-disability-proof']")).to be_present
        end

        it "has all followups primary is not senior" do
          intake.update(primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1))
          intake.update(spouse_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 66), 1, 1))
          get :edit

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("input[data-follow-up='#primary-disability-proof']")).to be_present
          expect(html.at_css("input[data-follow-up='#spouse-disability-proof']")).to be_present
          expect(html.at_css("input[data-follow-up='#both-disability-proof']")).to be_present
        end

        it "has all followups when neither are senior" do
          intake.update(primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1))
          intake.update(spouse_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1))
          get :edit

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("input[data-follow-up='#primary-disability-proof']")).to be_present
          expect(html.at_css("input[data-follow-up='#spouse-disability-proof']")).to be_present
          expect(html.at_css("input[data-follow-up='#both-disability-proof']")).to be_present
        end

        it "has no followup id when both are senior" do
          intake.update(primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 66), 1, 1))
          intake.update(spouse_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 66), 1, 1))
          get :edit

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("input[data-follow-up='#primary-disability-proof']")).not_to be_present
          expect(html.at_css("input[data-follow-up='#spouse-disability-proof']")).not_to be_present
          expect(html.at_css("input[data-follow-up='#both-disability-proof']")).not_to be_present
        end
      end

      context "not mfj" do
        let(:intake) { create :state_file_md_intake, filing_status: "single" }

        it "has primary data followup when primary is not senior" do
          intake.update(primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 64), 1, 1))
          get :edit

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("input[data-follow-up='#primary-disability-proof']")).to be_present
          expect(html.at_css("input[data-follow-up='#spouse-disability-proof']")).not_to be_present
          expect(html.at_css("input[data-follow-up='#both-disability-proof']")).not_to be_present
        end

        it "does not have primary data followup when primary is senior" do
          intake.update(primary_birth_date: Date.new((MultiTenantService.statefile.current_tax_year - 66), 1, 1))
          get :edit

          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("input[data-follow-up='#primary-disability-proof']")).not_to be_present
          expect(html.at_css("input[data-follow-up='#spouse-disability-proof']")).not_to be_present
          expect(html.at_css("input[data-follow-up='#both-disability-proof']")).not_to be_present
        end
      end
    end
  end
end
