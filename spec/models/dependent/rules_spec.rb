require "rails_helper"

describe Dependent::Rules do
  let(:tax_year) { 2020 }
  let(:full_time_student_yes) { false }
  let(:permanently_totally_disabled_yes) { false }
  let(:qualifying_child_relationship) { false }
  let(:qualifying_relative_relationship) { false }
  let(:ssn_present) { false }
  let(:meets_misc_qualifying_relative_requirements) { false }
  let(:meets_qc_residence_condition_generic) { false }
  let(:meets_qc_claimant_condition) { false }
  let(:meets_qc_misc_conditions) { false }
  let(:subject) { described_class.new(birth_date, tax_year, full_time_student_yes, permanently_totally_disabled_yes, ssn_present, qualifying_child_relationship, qualifying_relative_relationship, meets_misc_qualifying_relative_requirements, meets_qc_residence_condition_generic, meets_qc_claimant_condition, meets_qc_misc_conditions) }

  describe ".born_in_final_6_months?" do
    context "when born on Jan 1" do
      let(:birth_date) { Date.new(tax_year, 1, 1) }

      it "is false" do
        expect(subject.born_in_final_6_months?).to be_falsey
      end
    end

    context "when born on June 30" do
      let(:birth_date) { Date.new(tax_year, 6, 30) }

      it "is true" do
        expect(subject.born_in_final_6_months?).to be_truthy
      end
    end

    context "when born on December 31" do
      let(:birth_date) { Date.new(tax_year, 12, 31) }

      it "is true" do
        expect(subject.born_in_final_6_months?).to be_truthy
      end
    end
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
      let(:full_time_student_yes) { true }
      let(:birth_date) { Date.new(tax_year - 20, 12, 25) }

      it "returns true" do
        expect(subject.meets_qc_age_condition?).to eq true
      end
    end

    context "with a dependent that is over 24 but disabled" do
      let(:permanently_totally_disabled_yes) { true }
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
    context "with a relationship that's normally a qualifying child" do
      let(:qualifying_child_relationship) { true }
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

  describe ".qualifying_relative?" do
    context "with an old dependent who meets misc requirements and has a ssn/itin/atin stored" do
      let(:meets_misc_qualifying_relative_requirements) { true }
      let(:ssn_present) { true }

      context "with a dependent who has a qualified child relationship but doesn't meet age conditions" do
        let(:birth_date) { Date.new(tax_year - 70, 12, 25) }
        let(:qualifying_child_relationship) { true }

        it "returns true" do
          expect(subject.qualifying_relative?).to eq true
        end

        context "when meet misc requirements are not met" do
          let(:meets_misc_qualifying_relative_requirements) { false }

          it "returns false" do
            expect(subject.qualifying_relative?).to eq false
          end
        end
      end

      context "with a dependent who has a qualified relative relationship" do
        let(:birth_date) { Date.new(tax_year - 30, 12, 25) }
        let(:qualifying_relative_relationship) { true }

        it "returns true" do
          expect(subject.qualifying_relative?).to eq true
        end

        context "when meet misc requirements are not met" do
          let(:meets_misc_qualifying_relative_requirements) { false }

          it "returns false" do
            expect(subject.qualifying_relative?).to eq false
          end
        end
      end
    end
  end

  describe ".meets_qc_residence_condition?" do
    context "when already generally meeting the qualified child residence conditions" do
      let(:meets_qc_residence_condition_generic) { true }

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
      let(:meets_qc_residence_condition_generic) { false }

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
    context "as a child who generally qualifies" do
      let(:qualifying_child_relationship) { true }
      let(:ssn_present) { true }
      let(:meets_qc_claimant_condition) { true }
      let(:meets_qc_misc_conditions) { true }

      context "when the child is < 6 months old" do
        let(:birth_date) { Date.new(tax_year, 12, 25) }

        it "returns true" do
          expect(subject.qualifying_child?).to eq(true)
        end

        context "and not born yet" do
          let(:birth_date) { Date.new(tax_year + 1, 1, 1) }
          it "returns false" do
            expect(subject.qualifying_child?).to eq(false)
          end
        end
      end

      context "when the child is about 1 year old" do
        let(:birth_date) { Date.new(tax_year, 1, 1) }

        context "when the residence condition is met" do
          let(:meets_qc_residence_condition_generic) { true }

          it "returns true" do
            expect(subject.qualifying_child?).to eq(true)
          end
        end

        context "when the residence condition is not met" do
          it "returns false" do
            expect(subject.qualifying_child?).to eq(false)
          end
        end
      end

      context "when the child is 40 years old and the residence condition is met" do
        let(:birth_date) { Date.new(tax_year - 40, 1, 1) }
        let(:meets_qc_residence_condition_generic) { true }

        it "returns false" do
          expect(subject.qualifying_child?).to eq(false)
        end
      end
    end
  end
end
