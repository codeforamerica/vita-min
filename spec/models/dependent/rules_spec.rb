require "rails_helper"

describe Dependent::Rules do
  subject { described_class.new(dependent, tax_year) }

  let(:tax_year) { 2020 }
  let(:birth_date) { Date.new(tax_year - 50, 11, 2) }
  let(:permanently_totally_disabled) { "no" }
  let(:full_time_student) { "no" }
  let(:relationship) { "daughter" }
  let(:meets_misc_qualifying_relative_requirements) { "no" }
  let(:ssn) { nil }
  let(:dependent) do
    create :dependent,
           relationship: relationship,
           full_time_student: full_time_student,
           permanently_totally_disabled: permanently_totally_disabled,
           ssn: ssn,
           meets_misc_qualifying_relative_requirements: meets_misc_qualifying_relative_requirements,
           birth_date: birth_date
  end

  before do
    allow(dependent).to receive(:meets_qc_residence_condition_generic?).and_return false
    allow(dependent).to receive(:meets_qc_claimant_condition?).and_return false
    allow(dependent).to receive(:meets_qc_misc_conditions?).and_return false
  end

  describe ".age" do
    context "when born on Jan 1 of the tax year" do
      let(:birth_date) { Date.new(tax_year, 1, 1) }

      it "is 0" do
        expect(subject.age).to eq(0)
      end
    end

    context "when born on Dec 31 of the previous year" do
      let(:birth_date) { Date.new(tax_year - 1, 12, 31) }

      it "is 1" do
        expect(subject.age).to eq(1)
      end
    end
  end

  describe ".meets_qc_age_condition?" do
    let(:permanently_totally_disabled) { "no" }
    context "with a dependent born after the tax year" do
      let(:birth_date) { Date.new(tax_year + 1, 1, 1) }

      it "returns false" do
        expect(subject.meets_qc_age_condition?).to eq false
      end
    end

    context "with a dependent that is under 19" do
      let(:birth_date) { Date.new(tax_year - 5, 12, 25) }

      it "returns true" do
        expect(subject.meets_qc_age_condition?).to eq true
      end
    end

    context "with a dependent that is between 19 and 24 and a full time student" do
      let(:full_time_student) { "yes" }
      let(:birth_date) { Date.new(tax_year - 20, 12, 25) }

      it "returns true" do
        expect(subject.meets_qc_age_condition?).to eq true
      end
    end

    context "with a dependent that is over 24 but disabled" do
      let(:permanently_totally_disabled) { "yes" }
      let(:birth_date) { Date.new(tax_year - 40, 12, 25) }

      it "returns true" do
        expect(subject.meets_qc_age_condition?).to eq true
      end
    end

    context "with a dependent that is over 19 and not a student, not disabled" do
      let(:birth_date) { Date.new(tax_year - 20, 12, 25) }

      it "returns false" do
        expect(subject.meets_qc_age_condition?).to eq false
      end
    end
  end

  describe ".disqualified_child_qualified_relative?" do
    context "when permanently and totally disabled" do
      let(:permanently_totally_disabled) { "yes" }
      let(:relationship) { "daughter" }
      it "returns false because they will be a qualified child due to disability logic" do
        expect(subject.disqualified_child_qualified_relative?).to eq(false)
      end
    end

    context "with a relationship that's normally a qualifying child" do
      let(:relationship) { "daughter" }

      context "when born after the current tax year" do
        let(:birth_date) { Date.new(tax_year + 1, 12, 25) }

        it "is not a qualified child or a qualified relative" do
          expect(subject.disqualified_child_qualified_relative?).to eq(false)
        end
      end

      context "when young" do
        let(:birth_date) { Date.new(tax_year - 2, 12, 25) }
        it "is not a disqualified-child child relative" do
          expect(subject.disqualified_child_qualified_relative?).to eq(false)
        end
      end

      context "when old" do
        let(:birth_date) { Date.new(tax_year - 40, 12, 25) }
        it "is a disqualified-child child relative" do
          expect(subject.disqualified_child_qualified_relative?).to eq(true)
        end
      end
    end

    context "with a relationship other than qualifying child" do
      let(:relationship) { "other" }
      let(:permanently_totally_disabled) { "yes" }
      context "when young" do
        let(:birth_date) { Date.new(tax_year - 2, 12, 25) }
        it "is not a disqualified-child child relative" do
          expect(subject.disqualified_child_qualified_relative?).to eq(false)
        end
      end

      context "when old" do
        let(:birth_date) { Date.new(tax_year - 40, 12, 25) }
        it "is not a disqualified-child child relative" do
          expect(subject.disqualified_child_qualified_relative?).to eq(false)
        end
      end
    end
  end

  describe "born_after_tax_year?" do
    context "when birth year is after the provided tax year" do
      let(:dependent) { create :dependent, birth_date: Date.today }
      it "returns true" do
        expect(dependent.born_after_tax_year?(TaxReturn.current_tax_year)).to eq true
      end
    end

    context "when birth year is before the provided tax year" do
      let(:dependent) { create :dependent, birth_date: 1.year.ago }
      it "returns false" do
        expect(dependent.born_after_tax_year?(TaxReturn.current_tax_year)).to eq false

      end
    end
  end

  describe ".qualifying_relative?" do
    context "with a dependent who has a qualified child relationship but doesn't meet age conditions" do
      let(:birth_date) { Date.new(tax_year - 70, 12, 25) }
      let(:relationship) { "daughter" }
      context "when misc requirements are met and has a ssn/itin/atin stored" do
        let(:ssn) { "123456789" }

        before do
          allow(dependent).to receive(:meets_misc_qualifying_relative_requirements_yes?).and_return true
        end

        it "returns true" do
          expect(subject.qualifying_relative?).to eq true
        end
      end

      context "when misc requirements are not met" do
        let(:ssn) { nil }

        before do
          allow(dependent).to receive(:meets_misc_qualifying_relative_requirements_yes?).and_return false
        end

        it "returns false" do
          expect(subject.qualifying_relative?).to eq false
        end
      end

      context "when ssn/itin/atin not present" do
        let(:ssn) { nil }

        before do
          allow(dependent).to receive(:meets_misc_qualifying_relative_requirements_yes?).and_return true
        end

        it "returns false" do
          expect(subject.qualifying_relative?).to eq false
        end
      end
    end

    context "with a dependent who has a qualified relative relationship" do
      let(:birth_date) { Date.new(tax_year - 30, 12, 25) }
      let(:qualifying_relative_relationship) { true }

      context "when misc requirements are met and has a ssn/itin/atin stored" do
        let(:ssn) { "123456789" }

        before do
          allow(dependent).to receive(:meets_misc_qualifying_relative_requirements_yes?).and_return true
        end

        it "returns true" do
          expect(subject.qualifying_relative?).to eq true
        end
      end

      context "when misc requirements are not met" do
        let(:ssn) { "123456789" }

        before do
          allow(dependent).to receive(:meets_misc_qualifying_relative_requirements_yes?).and_return false
        end

        it "returns false" do
          expect(subject.qualifying_relative?).to eq false
        end
      end

      context "when ssn/itin/atin not present" do
        let(:ssn) { nil }

        before do
          allow(dependent).to receive(:meets_misc_qualifying_relative_requirements_yes?).and_return true
        end

        it "returns false" do
          expect(subject.qualifying_relative?).to eq false
        end
      end
    end
  end

  describe ".meets_qc_residence_condition?" do
    context "when already generally meeting the qualified child residence conditions" do
      before do
        allow(dependent).to receive(:meets_qc_residence_condition_generic?).and_return true
      end

      context "when younger than 6 months" do
        let(:birth_date) { Date.new(tax_year, 12, 25) }
        it "returns true" do
          expect(subject.meets_qc_residence_condition?).to eq(true)
        end
      end

      context "when older than 6 months" do
        let(:birth_date) { Date.new(tax_year, 1, 1) }
        it "returns true" do
          expect(subject.meets_qc_residence_condition?).to eq(true)
        end
      end
    end

    context "when not generally meeting the qualified child residence conditions" do
      before do
        allow(dependent).to receive(:meets_qc_residence_condition_generic?).and_return false
      end

      context "when younger than 6 months" do
        let(:birth_date) { Date.new(tax_year, 12, 25) }
        it "returns true" do
          expect(subject.meets_qc_residence_condition?).to eq(true)
        end
      end

      context "when older than 6 months" do
        let(:birth_date) { Date.new(tax_year, 1, 1) }
        it "returns false" do
          expect(subject.meets_qc_residence_condition?).to eq(false)
        end
      end
    end
  end

  describe ".qualifying_child?" do
    let(:qualifying_child_relationship) { "daughter" }
    let(:ssn) { "123456789" }
    let(:birth_date) { Date.new(tax_year - 2, 1, 2) }
    before do
      allow(dependent).to receive(:meets_qc_claimant_condition?).and_return true
      allow(dependent).to receive(:meets_qc_residence_condition_generic?).and_return true
      allow(dependent).to receive(:meets_qc_misc_conditions?).and_return true
    end

    context "when all conditions are met" do
      it "returns true" do
        expect(subject.qualifying_child?).to eq true
      end
    end

    context "when not a qualifying child relationship" do
      let(:relationship) { "aunt" }

      it "returns false" do
        expect(subject.qualifying_child?).to eq false
      end
    end

    context "when ssn/itin/atin not present" do
      let(:ssn) { nil }

      it "returns false" do
        expect(subject.qualifying_child?).to eq false
      end
    end

    context "when not meeting the qualified child claimant condition" do
      before do
        allow(dependent).to receive(:meets_qc_claimant_condition?).and_return false
      end

      let(:meets_qc_claimant_condition) { false }

      it "returns false" do
        expect(subject.qualifying_child?).to eq false
      end
    end

    context "when not meeting the qualified child misc conditions" do
      before do
        allow(dependent).to receive(:meets_qc_misc_conditions?).and_return false
      end

      it "returns false" do
        expect(subject.qualifying_child?).to eq false
      end
    end

    context "when not meeting the age condition" do
      before do
        allow(subject).to receive(:meets_qc_age_condition?).and_return false
      end

      it "returns false" do
        expect(subject.qualifying_child?).to eq false
      end
    end

    context "when not meeting the residence condition" do
      before do
        allow(subject).to receive(:meets_qc_residence_condition?).and_return false
      end

      it "returns false" do
        expect(subject.qualifying_child?).to eq false
      end
    end
  end
end
