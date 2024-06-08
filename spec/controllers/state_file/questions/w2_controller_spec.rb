require "rails_helper"

RSpec.describe StateFile::Questions::W2Controller do
  let(:raw_direct_file_data) { File.read(Rails.root.join("spec/fixtures/state_file/fed_return_xmls/2023/ny/batman.xml")) }
  let(:direct_file_xml) { Nokogiri::XML(raw_direct_file_data) }
  let(:intake) do
    create :state_file_ny_intake, raw_direct_file_data: direct_file_xml.to_xml
  end
  before do
    Flipper.enable(:w2_override)
    sign_in intake
  end

  describe "#show?" do
    context "they have no issues with their fed xml w2s" do
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "with a broken w2" do
      context "StateWagesAmt is blank or missing" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("StateWagesAmt").content = ""
          xml
        end

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end
    end
  end

  describe "#index" do
    # must have invalid df w2s
    let(:direct_file_xml) do
      xml = super()
      xml.search("IRSW2").map do |w2|
        w2.at("StateWagesAmt").content = ""
      end
      xml
    end

    it "renders index of invalid w2s with w2_index as id" do
      get :index, params: { us_state: :ny }

      w2s_list = assigns(:w2s)
      expect(w2s_list.count).to eq 2
      expect(w2s_list[0].w2_index).to eq 0
      expect(w2s_list[1].w2_index).to eq 1

      # TODO: render_views and check that id in link is w2_index?
    end

    context "with both valid and invalid W2s" do
      let(:direct_file_xml) do
        xml = super()
        # Lets fix the first W2...
        xml.at("StateWagesAmt").content = "600"
        xml
      end

      it "filters correctly" do
        get :index, params: { us_state: :ny }
        w2s_list = assigns(:w2s)
        expect(w2s_list.count).to eq 1
        expect(w2s_list[0].w2_index).to eq 1
      end
    end

    context "with a single invalid W2" do
      let(:direct_file_xml) do
        xml = super()
        xml.at("IRSW2").remove
        xml
      end

      it "redirects to the edit page" do
        get :index, params: { us_state: :ny }
        expect(response).to redirect_to "/en/ny/questions/w2/0/edit"
      end
    end
  end

  describe "#update" do
    # df w2s must be invalid
    let(:direct_file_xml) do
      xml = super()
      xml.search("IRSW2").map do |w2|
        w2.at("StateWagesAmt").content = ""
      end
      xml
    end

    context "with valid params" do
      let(:params) do
        {
          us_state: "ny",
          id: 1,
          state_file_w2: {
            employer_state_id_num: "12345",
            state_wages_amt: 10000,
            state_income_tax_amt: 500,
            local_wages_and_tips_amt: 40,
            local_income_tax_amt: 30,
            locality_nm: "NYC"
          }
        }
      end

      context "when the client got here from the review flow" do
        let!(:w2) { create :state_file_w2, state_file_intake: intake, w2_index: 1 }
        let!(:other_w2) { create :state_file_w2, state_file_intake: intake, w2_index: 0, state_wages_amt: 8000 }

        # can't use shared example here because it's written for the default update in QuestionsController
        it "redirects to the review page" do
          post :update, params: params.merge(return_to_review: "y")

          expect(response).to redirect_to(StateFile::Questions::NyReviewController.to_path_helper(us_state: :ny, action: :edit))
        end

        it "redirects to the review page" do
          post :create, params: params.merge(return_to_review: "y")

          expect(response).to redirect_to(StateFile::Questions::NyReviewController.to_path_helper(us_state: :ny, action: :edit))
        end
      end

      context "with existing w2" do
        let!(:w2) { create :state_file_w2, state_file_intake: intake, w2_index: 1 }
        let!(:other_w2) { create :state_file_w2, state_file_intake: intake, w2_index: 0, state_wages_amt: 8000 }

        it "updates the w2 and redirects to the index" do
          expect {
            post :update, params: params
          }.not_to change(StateFileW2, :count)

          w2.reload
          expect(w2.state_file_intake).to eq intake
          expect(w2.employer_state_id_num).to eq "12345"
          expect(w2.state_wages_amt).to eq 10000
          expect(w2.state_income_tax_amt).to eq 500
          expect(w2.local_wages_and_tips_amt).to eq 40
          expect(w2.local_income_tax_amt).to eq 30
          expect(w2.locality_nm).to eq "NYC"

          # TODO: check other_w2 hasn't been updated? perhaps unnecessary test

          expect(response).to redirect_to(StateFile::Questions::W2Controller.to_path_helper(us_state: :ny, action: :index))
        end
      end

      context "without existing w2" do
        it "creates new w2 and redirects to the index" do
          expect {
            post :update, params: params
          }.to change(StateFileW2, :count).by(1)

          new_w2 = StateFileW2.last

          expect(new_w2.w2_index).to eq 1
          expect(new_w2.state_file_intake).to eq intake
          expect(new_w2.employer_state_id_num).to eq "12345"
          expect(new_w2.state_wages_amt).to eq 10000
          expect(new_w2.state_income_tax_amt).to eq 500
          expect(new_w2.local_wages_and_tips_amt).to eq 40
          expect(new_w2.local_income_tax_amt).to eq 30
          expect(new_w2.locality_nm).to eq "NYC"

          expect(response).to redirect_to(StateFile::Questions::W2Controller.to_path_helper(us_state: :ny, action: :index))
        end
      end

      context "with a hacker trying to change the owner of a w2" do
        let(:intake2) do
          create :state_file_ny_intake, raw_direct_file_data: direct_file_xml.to_xml
        end
        let!(:w2) { create :state_file_w2, state_file_intake: intake, w2_index: 0, state_wages_amt: 8000 }
        let(:params) do
          p = super()
          p.merge({
            id: 0,
            state_file_w2: p[:state_file_w2].merge({
              state_file_intake_id: intake2.id
            })
          })
        end

        it "ignores attempts to change the intake of a w2" do
          expect {
            post :update, params: params
          }.not_to change(StateFileW2, :count)
          w2.reload
          expect(w2.state_file_intake_id).to eq(intake.id)
        end
      end

      context "with a hacker add w2s" do
        let(:params) do
          super().merge({ id: 2 })
        end

        it "throws an error" do
          expect {
            post :update, params: params
          }.to raise_error
        end
      end

      context "with a single invalid w2" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("IRSW2").remove
          xml
        end
        let(:params) do
          super().merge({id: 0})
        end

        it "redirects to the next page in the flow" do
          post :update, params: params
          expect(response).to redirect_to "/en/ny/questions/ny-sales-use-tax"
        end

        context "when the client got here from the review flow" do
          it_behaves_like :return_to_review_concern do
            let(:form_params) { params }
          end
        end
      end
    end

    context "with invalid params" do
      render_views
      let(:params) do
        {
          us_state: :ny,
          id: 0,
          state_file_w2: {
            employer_state_id_num: "12345",
            state_wages_amt: 0,
            state_income_tax_amt: 500,
            local_wages_and_tips_amt: 20,
            local_income_tax_amt: 30,
            locality_nm: "NYC"
          }
        }
      end

      it "renders edit with validation errors" do
        post :update, params: params

        expect(response).to render_template(:edit)
        expect(response.body).to include "Cannot be greater than State wages and tips."
      end
    end
  end

  context "with an intake from AZ" do
    let(:raw_direct_file_data) { File.read(Rails.root.join("spec/fixtures/state_file/fed_return_xmls/2023/az/bert.xml")) }
    let(:direct_file_xml) do
      doc = super()
      # Bert paid more tax than his wages!
      doc.at("StateIncomeTaxAmt").content = "9001"
      doc
    end
    let(:intake) do
      create :state_file_az_intake, raw_direct_file_data: direct_file_xml.to_xml
    end

    context "shows when there a w2 is sus" do
      it "returns false" do
        expect(described_class.show?(intake)).to eq true
      end
    end
  end

  describe "#create" do
    context "with a sus but valid w2" do
      let(:direct_file_xml) do
        xml = super()
        xml.at("StateWagesAmt").content = ""
        xml
      end

      it "rerenders the index with errors if no override is persisted" do
        post :create, params: { us_state: :ny, locale: :en }
        expect(response).to render_template(:index)
      end

      context "with a persisted override" do
        let!(:w2) { create :state_file_w2, state_file_intake: intake, w2_index: 0, state_wages_amt: 8000 }

        it "redirects to the next path" do
          post :create, params: { us_state: :ny, locale: :en }
          expect(response).to redirect_to("/en/ny/questions/ny-sales-use-tax")
        end
      end
    end
  end
end