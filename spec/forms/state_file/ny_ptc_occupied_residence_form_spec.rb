require "rails_helper"

RSpec.describe StateFile::NyPtcOccupiedResidenceForm do
  let(:intake) { create :state_file_ny_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "occupied_residence is required" do
        let(:invalid_params) do
          {
            occupied_residence: nil,
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

          expect(form.errors[:occupied_residence]).to include "Can't be blank."
        end
      end

      xcontext "they answered no" do
        context "they did not provide an address or check the box" do
          let(:invalid_params) do
            {
              occupied_residence: "no",
              # permanent_apartment: nil,
              # permanent_city: nil,
              # permanent_street: nil,
              # permanent_zip: nil
            }
          end

          it "is invalid" do
            expect(form.valid?).to eq false
            # expect(form.errors[:permanent_city]).to include "Can't be blank."
            # expect(form.errors[:permanent_street]).to include "Can't be blank."
            # expect(form.errors[:permanent_zip]).to include "Can't be blank."
          end
        end

        #  TODO decide what to do if they check the box AND provide an address
      end
    end
  end

  describe "save" do
    let(:form) { described_class.new(intake, valid_params) }
    let(:valid_params) do
      {
        occupied_residence: "yes",
      }
    end

    it "saves imported_permanent_address_confirmed as true" do
      expect(form.valid?).to eq true
      form.save

      expect(intake.occupied_residence).to eq "yes"
    end
  end
end
