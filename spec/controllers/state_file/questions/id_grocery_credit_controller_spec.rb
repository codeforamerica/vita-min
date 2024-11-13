require 'rails_helper'

describe StateFile::Questions::IdGroceryCreditController do
  let(:intake) { create :state_file_id_intake }

  before do
    sign_in intake
  end

  describe ".show?" do
    context "with a primary filer who is claimed as a dependent" do
      before do
        allow_any_instance_of(DirectFileData).to receive(:claimed_as_dependent?).and_return(true)
      end

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "with a primary filer who is not claimed as a dependent" do
      it "returns true" do
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
  end
end
