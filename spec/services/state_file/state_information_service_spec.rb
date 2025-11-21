require "rails_helper"

describe StateFile::StateInformationService do
  describe ".active_state_codes" do
    it "returns the list of state codes as strings" do
      expect(described_class.active_state_codes).to match_array ["az", "id", "md", "nc", "nj", "ny"]
    end
  end

  describe ".state_code_to_name_map" do
    it "returns a map of all the state codes to state names" do
      result = {
        "az" => "Arizona",
        "md" => "Maryland",
        "nc" => "North Carolina",
        "nj" => "New Jersey",
        "ny" => "New York",
        "id" => "Idaho",
      }
      expect(described_class.state_code_to_name_map).to eq result
    end
  end

  describe ".state_intake_classes" do
    it "returns an array of the intake classes" do
      expect(described_class.state_intake_classes).to match_array [StateFileAzIntake, StateFileIdIntake, StateFileMdIntake, StateFileNcIntake, StateFileNjIntake, StateFileNyIntake]
    end
  end

  describe ".state_intake_class_names" do
    it "returns an array of the intake classes as strings" do
      expect(described_class.state_intake_class_names).to match_array ["StateFileAzIntake", "StateFileIdIntake", "StateFileMdIntake", "StateFileNcIntake", "StateFileNjIntake", "StateFileNyIntake"]
    end
  end

  context "locale-aware methods" do
    around do |example|
      I18n.with_locale(:es) do
        example.run
      end
    end

    describe ".state_name" do
      it "is locale aware" do
        expected = "Carolina del Norte"
        actual = described_class.send(:state_name, "nc")
        expect(actual).to eq(expected)
      end

      it "throw an error for an invalid state code" do
        expect do
          described_class.send(:state_name, "boop")
        end.to raise_error(InvalidStateCodeError, "Invalid state code: boop")
      end
    end

    describe ".department_of_taxation" do
      it "is locale aware" do
        expected = "Departamento de Ingresos de Carolina del Norte"
        actual = described_class.send(:department_of_taxation, "nc")
        expect(actual).to eq(expected)
      end

      it "throw an error for an invalid state code" do
        expect do
          described_class.send(:department_of_taxation, "boop")
        end.to raise_error(InvalidStateCodeError, "Invalid state code: boop")
      end
    end
  end

  described_class::GETTER_METHODS.each do |getter_method|
    describe ".#{getter_method}" do
      described_class.active_state_codes.each do |state_code|
        it "defines the method for #{state_code}" do
          expect(described_class.send(getter_method, state_code)).not_to be_nil
        end

        it "throws an error for an invalid state code" do
          expect do
            described_class.send(getter_method, "boop")
          end.to raise_error(InvalidStateCodeError, "Invalid state code: boop")
        end
      end
    end
  end
end
