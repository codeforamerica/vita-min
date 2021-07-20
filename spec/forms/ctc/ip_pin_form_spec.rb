require "rails_helper"

describe Ctc::IpPinForm do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake }

  let(:params) do
    {
      has_primary_ip_pin: "yes",
      has_spouse_ip_pin: "yes",
      dependents_attributes: {
        "0" => {
          id: dependent.id,
          has_ip_pin: "yes"
        }
      }
    }
  end

  describe "validates" do
    context "if no options are selected" do
      before do
        params[:has_primary_ip_pin] = "unfilled"
        params[:has_spouse_ip_pin] = "unfilled"
        params[:dependents_attributes]["0"][:has_ip_pin] = "unfilled"
      end

      it "shows error on ‘None of the above’ option" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors.keys).to match_array([:no_ip_pins])
      end
    end
  end

  context "save" do
    it "persists booleans on the intake and dependents" do
      described_class.new(intake, params).save

      expect(intake.reload).to be_has_primary_ip_pin_yes
      expect(intake.reload).to be_has_spouse_ip_pin_yes
      expect(dependent.reload).to be_has_ip_pin_yes
    end

    context "with no spouse or dependents" do
      before do
        params.delete(:has_spouse_ip_pin)
        params.delete(:dependents_attributes)
      end

      it "can accept and save just the primary flag without incident" do
        described_class.new(intake, params).save

        expect(intake.reload).to be_has_primary_ip_pin_yes
      end
    end
  end
end
