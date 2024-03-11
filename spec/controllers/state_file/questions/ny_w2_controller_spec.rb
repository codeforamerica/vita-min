require "rails_helper"

RSpec.describe StateFile::Questions::NyW2Controller do
  let(:raw_direct_file_data) { File.read(Rails.root.join("spec/fixtures/files/fed_return_batman_ny.xml")) }
  let(:direct_file_xml) { Nokogiri::XML(raw_direct_file_data) }
  let(:intake) do
    create :state_file_ny_intake, raw_direct_file_data: direct_file_xml.to_xml
  end
  before do
    Flipper.enable(:w2_override)
    sign_in intake
  end

  describe ".show?" do
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

      context "LocalWagesAndTipsAmt is missing" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalWagesAndTipsAmt").content = ""
          xml.at("LocalIncomeTaxAmt").content = ""
          xml
        end

        context "client indicated they were a full year NYC resident" do
          it "returns true" do
            intake.update(nyc_residency: :full_year)
            expect(described_class.show?(intake)).to eq true
          end
        end

        context "client was not an NYC resident" do
          it "returns false" do
            intake.update(nyc_residency: :none)
            expect(described_class.show?(intake)).to eq false
          end
        end
      end

      context "client indicated they were an NYC resident on nyc-residency and LocalityNm is missing" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalityNm").content = ""
          xml
        end

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "LocalityNm is blank" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalityNm").content = ""
          xml
        end
        before do
          intake.update(nyc_residency: :none)
        end

        context "LocalWagesAndTipsAmt is present" do
          let(:direct_file_xml) do
            xml = super()
            xml.at("LocalIncomeTaxAmt").content = ""
            xml
          end

          it "returns true" do
            expect(described_class.show?(intake)).to eq true
          end
        end

        context "LocalIncomeTaxAmt is present" do
          let(:direct_file_xml) do
            xml = super()
            xml.at("LocalWagesAndTipsAmt").content = ""
            xml
          end

          it "returns true" do
            expect(described_class.show?(intake)).to eq true
          end
        end

        context "neither LocalWagesAndTipsAmt nor LocalIncomeTaxAmt is present" do
          let(:direct_file_xml) do
            xml = super()
            xml.at("LocalWagesAndTipsAmt").content = ""
            xml.at("LocalIncomeTaxAmt").content = ""
            xml
          end

          it "returns false" do
            expect(described_class.show?(intake)).to eq false
          end
        end
      end

      context "LocalIncomeTaxAmt is present but LocalWagesAndTipsAmt is not" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalWagesAndTipsAmt").content = ""
          xml
        end

        it "returns true" do
          intake.update(nyc_residency: :none)
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "StateIncomeTaxAmt is present but StateWagesAmt is not" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("StateWagesAmt").content = ""
          xml
        end

        it "returns true" do
          intake.update(nyc_residency: :none)
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "StateWagesAmt is present but EmployerStateIdNum is not" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("EmployerStateIdNum").content = ""
          xml
        end

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "LocalityNm does not match one of the NY Pub 93 list of allowed values" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalityNm").content = "Not New York"
          xml
        end

        it "returns true" do
          intake.update(nyc_residency: :none)
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "StateAbberviationCd is blank or missing" do
        let(:direct_file_xml) do
          xml = super()
          xml.search("W2StateTaxGrp StateAbbreviationCd").each { |node| node.remove }
          xml
        end

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "StateIncomeTaxAmt is greater than StateWagesAmt" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("StateIncomeTaxAmt").content = "9000"
          xml
        end

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "LocalIncomeTaxAmt is greater than LocalWagesAndTipsAmt" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalIncomeTaxAmt").content = "9000"
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
        expect(response).to redirect_to "/en/ny/questions/ny_w2/0/edit"
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
          us_state: :ny,
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

          expect(response).to redirect_to(StateFile::Questions::NyW2Controller.to_path_helper(us_state: :ny, action: :index))
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

          expect(response).to redirect_to(StateFile::Questions::NyW2Controller.to_path_helper(us_state: :ny, action: :index))
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

        it "redirects to the edit page" do
          post :update, params: params
          expect(response).to redirect_to "/en/ny/questions/ny-sales-use-tax"
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
end