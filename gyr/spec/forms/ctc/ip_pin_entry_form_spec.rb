require "rails_helper"

describe Ctc::IpPinEntryForm do
  let(:intake) { create :ctc_intake, has_primary_ip_pin: "yes", has_spouse_ip_pin: "yes" }
  let(:dependent) { create :dependent, intake: intake, has_ip_pin: "yes" }

  let(:params) do
    {
      primary_ip_pin: " 123456",
      spouse_ip_pin: "123457",
      dependents_attributes: {
        "0" => {
          id: dependent.id,
          ip_pin: "123458"
        }
      }
    }
  end

  describe "#dependents" do
    let(:subject) { described_class.new(intake, params) }
    let!(:dependent) { create(:dependent, intake: intake, has_ip_pin: has_ip_pin) }

    context "with a dependent who has an IP PIN" do
      let(:has_ip_pin) { "yes" }

      it "returns an array with that dependent" do
        expect(subject.dependents).to match_array([dependent])
      end
    end

    context "with a dependent who has no IP PIN" do
      let(:has_ip_pin) { "no" }

      it "returns an empty array" do
        expect(subject.dependents).to match_array([])
      end
    end
  end

  describe "validates" do
    context "if pins are in the wrong format" do
      before do
        params[:primary_ip_pin] = "abc"
        params[:spouse_ip_pin] = "123456789"
        params[:dependents_attributes]["0"][:ip_pin] = "-53.4"
      end

      it "shows errors on each empty field" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to match_array([:primary_ip_pin, :spouse_ip_pin])
        expect(form.dependents.first.errors.attribute_names).to match_array([:ip_pin])
      end

      it "displays the errored values on dependents" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.dependents.first.ip_pin).to eq("-53.4")
      end
    end

    context "if pins are not entered" do
      before do
        params[:primary_ip_pin] = ""
        params[:spouse_ip_pin] = ""
        params[:dependents_attributes]["0"][:ip_pin] = ""
      end

      it "shows errors on each empty field" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to match_array([:primary_ip_pin, :spouse_ip_pin])
        expect(form.dependents.first.errors.attribute_names).to match_array([:ip_pin])
      end
    end

    context "if pins are all zeros" do
      before do
        params[:primary_ip_pin] = "000000"
        params[:spouse_ip_pin] = "000000"
        params[:dependents_attributes]["0"][:ip_pin] = "000000"
      end

      it "shows errors on each field" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to match_array([:primary_ip_pin, :spouse_ip_pin])
        expect(form.dependents.first.errors.attribute_names).to match_array([:ip_pin])
      end
    end
  end

  context "save" do
    let(:subject) { described_class.new(intake, params) }

    before { subject.valid? }

    it "persists ip pins on the intake and dependents" do
      subject.save

      intake.reload
      expect(intake.primary_ip_pin).to eq('123456')
      expect(intake.spouse_ip_pin).to eq('123457')
      expect(dependent.reload.ip_pin).to eq('123458')
    end
  end
end
