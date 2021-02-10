require "rails_helper"

describe DiyLocationForm do
  let(:diy_intake) {
    build :diy_intake
  }

  describe "validations" do
    let(:valid_params) {
      {
        zip_code: "80304",
      }
    }

    context "with a valid params" do
      it "is valid" do
        diy_location_form = DiyLocationForm.new(diy_intake, valid_params)

        expect(diy_location_form.valid?).to eq true
      end
    end

    context "with invalid zip codes" do
      it "is not valid" do
        valid_params[:zip_code] = ""
        diy_location_form = DiyLocationForm.new(diy_intake, valid_params)

        expect(diy_location_form.valid?).to eq false
        expect(diy_location_form.errors.full_messages).to eq ["Zip code Please enter a valid 5-digit zip code."]

        valid_params[:zip_code] = "asdf"
        diy_location_form = DiyLocationForm.new(diy_intake, valid_params)

        expect(diy_location_form.valid?).to eq false
        expect(diy_location_form.errors.full_messages).to eq ["Zip code Please enter a valid 5-digit zip code."]
      end
    end
  end
end