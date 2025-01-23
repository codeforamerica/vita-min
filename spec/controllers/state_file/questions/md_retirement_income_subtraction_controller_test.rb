require "rails_helper"

describe StateFile::Questions::MdRetirementIncomeSubtractionController do
  let(:intake) { create :state_file_md_intake}

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
    let!(:first_1099r) { create :state_file1099_r, intake: intake, payer_name: "First Payer", recipient_name: "First Recipient", taxable_amount: 1111 }
    let!(:second_1099r) { create :state_file1099_r, intake: intake, payer_name: "Second Payer", recipient_name: "Second Recipient", taxable_amount: 2222 }

    render_views

    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end

    context "when an index is not provided" do
      it "renders the data for the first 1099R" do
        get :edit
        expect(response.body).to include("First Payer")
        expect(response.body).to include("$1,111")
        expect(response.body).to include("First Recipient")

        expect(response.body).not_to include("Second Payer")
        expect(response.body).not_to include("$2,222")
        expect(response.body).not_to include("Second Recipient")
      end
    end

    context "when an index param is provided" do
      it "renders the data for the 1099R at that index" do
        get :edit, params: { index: 1 }
        expect(response.body).to include("Second Payer")
        expect(response.body).to include("$2,222")
        expect(response.body).to include("Second Recipient")

        expect(response.body).not_to include("First Payer")
        expect(response.body).not_to include("$1,111")
        expect(response.body).not_to include("First Recipient")
      end
    end

    context "when an invalid index param is provided" do
      it "renders a 404" do
        get :edit, params: { index: 2 }
        expect(response).to be_not_found
      end
    end
  end

  describe "#next_path" do
    let!(:first_1099r) { create :state_file1099_r, intake: intake }
    let!(:second_1099r) { create :state_file1099_r, intake: intake }

    context 'when not return_to_review' do
      context "when there are additional 1099Rs to view" do
        it "next path is MdRetirementIncomeSubtractionController with new index set" do
          post :update
          expect(subject.next_path).to eq("/en/questions/md-retirement-income-subtraction?index=1")
        end
      end

      context "when there are no additional 1099Rs to view" do
        it "next path is whichever is next overall" do
          post :update, params: {index: "1"}
          allow_any_instance_of(described_class.superclass).to receive(:next_path).and_return("/mocked/super/path")
          expect(subject.next_path).to eq("/mocked/super/path")
        end
      end
    end

    context 'when return_to_review' do
      context "when there are additional 1099Rs to view" do
        it "next path is MdRetirementIncomeSubtractionController with new index set and review param" do
          post :update, params: { return_to_review: "y" }
          expect(subject.next_path).to eq("/en/questions/md-retirement-income-subtraction?index=1&return_to_review=y")
        end
      end

      context "when there are no additional 1099Rs to view" do
        it "next path is Review Controller" do
          post :update, params: {index: "1", return_to_review: "y"}
          expect(subject.next_path).to eq("/en/questions/#{intake.state_code}-review")
        end
      end
    end
  end

  describe "#prev_path" do
    let!(:first_1099r) { create :state_file1099_r, intake: intake }
    let!(:second_1099r) { create :state_file1099_r, intake: intake }

    context 'when not return_to_review' do
      context "when there are previous 1099Rs to view" do
        it "prev path is MdRetirementIncomeSubtractionController with prev index set" do
          get :edit, params: { index: "1" }
          expect(subject.prev_path).to eq("/en/questions/md-retirement-income-subtraction?index=0")
        end
      end

      context "when there are no previous 1099Rs to view" do
        it "prev path is whichever is previous overall" do
          get :edit
          allow_any_instance_of(described_class.superclass).to receive(:prev_path).and_return("/mocked/super/path")
          expect(subject.prev_path).to eq("/mocked/super/path")
        end
      end
    end

    context 'when return_to_review' do
      context "when there are previous 1099Rs to view" do
        it "prev path is MdRetirementIncomeSubtractionController with prev index and return to review set" do
          get :edit, params: { index: "1", return_to_review: "y" }
          expect(subject.prev_path).to eq("/en/questions/md-retirement-income-subtraction?index=0&return_to_review=y")
        end
      end

      context "when there are no previous 1099Rs to view" do
        it "prev path is review screen" do
          get :edit, params: { return_to_review: "y" }
          expect(subject.prev_path).to eq("/en/questions/#{intake.state_code}-review")
        end
      end
    end
  end

end