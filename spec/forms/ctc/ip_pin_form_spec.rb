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
      },
      no_ip_pins: "no"
    }
  end

  describe "validates" do
    context "if no options are selected" do
      context "with dependents" do
        before do
          params[:has_primary_ip_pin] = "unfilled"
          params[:has_spouse_ip_pin] = "unfilled"
          params[:dependents_attributes]["0"][:has_ip_pin] = "unfilled"
        end

        it "shows error on ‘None of the above’ option" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors.attribute_names).to match_array([:no_ip_pins])
        end
      end

      context "without dependents" do
        before do
          params[:has_primary_ip_pin] = "unfilled"
          params[:has_spouse_ip_pin] = "unfilled"
          params.delete(:dependents_attributes)
        end

        it "shows error on ‘None of the above’ option" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors.attribute_names).to match_array([:no_ip_pins])
        end
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

    context "when returning to unset the checkbox after an ip pin was previously saved" do
      let(:params) { {
        has_primary_ip_pin: "yes",
        has_spouse_ip_pin: "no",
        dependents_attributes: {
          "0" => {
            id: dependent.id,
            has_ip_pin: "no"
          }
        },
        no_ip_pins: "no"
      } }

      let(:intake) { create :ctc_intake, has_primary_ip_pin: "yes", primary_ip_pin: "123456", has_spouse_ip_pin: "yes", spouse_ip_pin: "123457" }
      let(:dependent) { create :dependent, intake: intake, has_ip_pin: "yes", ip_pin: "123458" }

      it "removes their IP PINs" do
        described_class.new(intake, params).save

        intake.reload
        dependent.reload

        expect(intake.has_primary_ip_pin).to eq("yes")
        expect(intake.primary_ip_pin).to eq("123456")
        expect(intake.has_spouse_ip_pin).to eq("no")
        expect(intake.spouse_ip_pin).to be_nil
        expect(dependent.has_ip_pin).to eq("no")
        expect(dependent.ip_pin).to be_nil
      end
    end

    context "when choosing None of the above" do
      context "when some people on the return had IP PINs" do
        let(:params) { {
          has_primary_ip_pin: "no",
          has_spouse_ip_pin: "no",
          dependents_attributes: {
            "0" => {
              id: dependent.id,
              has_ip_pin: "no"
            }
          },
          no_ip_pins: "yes"
        } }
        let(:intake) { create :ctc_intake, has_primary_ip_pin: "yes", primary_ip_pin: "123456", has_spouse_ip_pin: "yes", spouse_ip_pin: "123457" }
        let(:dependent) { create :dependent, intake: intake, has_ip_pin: "yes", ip_pin: "123458" }

        it "removes their IP PINs" do
          described_class.new(intake, params).save

          intake.reload
          dependent.reload

          expect(intake.has_primary_ip_pin).to eq("no")
          expect(intake.primary_ip_pin).to be_nil
          expect(intake.has_spouse_ip_pin).to eq("no")
          expect(intake.spouse_ip_pin).to be_nil
          expect(dependent.has_ip_pin).to eq("no")
          expect(dependent.ip_pin).to be_nil
        end
      end
    end
  end
end
