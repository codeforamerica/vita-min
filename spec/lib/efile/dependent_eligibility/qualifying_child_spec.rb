require "rails_helper"

describe Efile::DependentEligibility::QualifyingChild do
  subject { described_class.new(dependent, TaxReturn.current_tax_year) }

  context "when passing an EfileSubmissionDependent who already has their qualification persisted on the record" do
    let(:dependent) { EfileSubmissionDependent.create(efile_submission: (create :efile_submission), dependent: (create :dependent), qualifying_child: true) }
    it "does not run the qualifying logic again because they are 'prequalified'" do
      expect(Efile::DependentEligibility::QualifyingChild.new(dependent, TaxReturn.current_tax_year).qualifies?).to eq true
      expect(Efile::DependentEligibility::QualifyingChild.new(dependent, TaxReturn.current_tax_year).is_submission_dependent?).to eq true
    end
  end

  context 'with a totally qualifying child' do
    let(:dependent) { create :qualifying_child }
    let(:test_result) do
      {
          relationship_test: true,
          married_filing_joint_test: true,
          tin_test: true,
          birth_test: true,
          age_test: true,
          financial_support_test: true,
          residence_test: true,
          claimable_test: true
      }
    end

    it "returns true for #qualifies?" do
      expect(subject.qualifies?).to eq true
    end

    it "has the raw test_results with all true values" do
      expect(subject.test_results).to eq test_result
    end

    it "has an empty array for disqualifiers" do
      expect(subject.disqualifiers).to eq []
    end
  end

  describe "relationship_test" do
    let(:relationship) { "daughter" }
    let(:dependent) { create :qualifying_child, relationship: relationship }
    context "when relationship qualifies" do
      it "passes the relationship test" do
        expect(subject.test_results[:relationship_test]).to eq true
        expect(subject.qualifies?).to eq true
      end
    end

    context "when relationship does not qualify" do
      let(:relationship) { "aunt" }
      it "fails the relationship test" do
        expect(subject.test_results[:relationship_test]).to eq false
        expect(subject.qualifies?).to eq false
        expect(subject.disqualifiers).to eq [:relationship_test]
      end
    end
  end

  describe "birth_test" do
    # A special age test that disqualifies people when they're born AFTER the tax year
    context "when < 0" do
      let(:dependent) { create :qualifying_child, birth_date: birth_date }
      let(:birth_date) { Date.new(TaxReturn.current_tax_year + 1, 1, 1) }

      context "even when disabled" do
        let(:permanently_totally_disabled) { "yes" }
        it "does not qualify" do
          expect(subject.test_results[:birth_test]).to eq false
          expect(subject.qualifies?).to eq false
          expect(subject.disqualifiers).to eq [:birth_test]
        end
      end
    end
  end

  describe "age_test" do
    let(:totally_permanently_disabled) { "no" }
    let(:full_time_student) { "no" }
    let(:birth_date) { Date.today - 25.years }
    let(:dependent) { create :qualifying_child, permanently_totally_disabled: permanently_totally_disabled, full_time_student: full_time_student, birth_date: birth_date }

    context "when < 19" do
      let(:birth_date) { Date.new(TaxReturn.current_tax_year, 1, 1) - 18.years }

      context "when not a full time student and not disabled" do
        let(:permanently_totally_disabled) { "no" }
        let(:full_time_student) { "no" }
        it "passes" do
          expect(subject.test_results[:age_test]).to eq true
          expect(subject.qualifies?).to eq true
        end
      end
    end

    context "when > 19, < 24" do
      let(:birth_date) { Date.new(TaxReturn.current_tax_year, 1, 1) - 23.years }

      context "when not a full time student, not disabled" do
        let(:permanently_totally_disabled) { "no" }
        let(:full_time_student) { "no" }
        it "fails" do
          expect(subject.test_results[:age_test]).to eq false
          expect(subject.qualifies?).to eq false
          expect(subject.disqualifiers).to eq [:age_test]
        end
      end

      context "when a full time student, not disabled" do
        let(:permanently_totally_disabled) { "no" }
        let(:full_time_student) { "yes" }
        it "passes" do
          expect(subject.test_results[:age_test]).to eq true
          expect(subject.qualifies?).to eq true
        end
      end

      context "when disabled" do
        let(:permanently_totally_disabled) { "yes" }
        let(:full_time_student) { "no" }
        it "passes" do
          expect(subject.test_results[:age_test]).to eq true
          expect(subject.qualifies?).to eq true
        end
      end
    end
    context "when > 24 " do
      let(:birth_date) { Date.new(TaxReturn.current_tax_year, 1, 1) - 25.years }

      context "when not a full time student and not disabled" do
        let(:permanently_totally_disabled) { "no" }
        let(:full_time_student) { "no" }
        it "fails" do
          expect(subject.test_results[:age_test]).to eq false
          expect(subject.qualifies?).to eq false
          expect(subject.disqualifiers).to eq [:age_test]
        end
      end

      context "when is not disabled, is full time student" do
        let(:permanently_totally_disabled) { "no" }
        let(:full_time_student) { "yes" }
        it "fails" do
          expect(subject.test_results[:age_test]).to eq false
          expect(subject.qualifies?).to eq false
          expect(subject.disqualifiers).to eq [:age_test]
        end
      end

      context "when permanently disabled" do
        let(:permanently_totally_disabled) { "yes" }
        let(:full_time_student) { "yes" }
        it "passes" do
          expect(subject.test_results[:age_test]).to eq true
        end
      end
    end

    context "when totally disabled" do
      let(:totally_permanently_disabled) { "yes" }
      let(:full_time_student) { "no" }
      let(:birth_date) { Date.today - 40.years }
    end
  end

  describe "married_filing_joint_test" do
    let(:dependent) { create :qualifying_child, filed_joint_return: filed_joint_return }
    context "when the dependent is filing with a spouse" do
      let(:filed_joint_return) { "yes" }
      it "fails" do
        expect(subject.test_results[:married_filing_joint_test]).to eq false
        expect(subject.qualifies?).to eq false
        expect(subject.disqualifiers).to eq [:married_filing_joint_test]
      end
    end

    context "when filed_joint_return is no" do
      let(:filed_joint_return) { "no" }
      it "fails" do
        expect(subject.test_results[:married_filing_joint_test]).to eq true
        expect(subject.qualifies?).to eq true
      end
    end

    context "when filed_joint_return is unfilled" do
      let(:filed_joint_return) { "unfilled" }
      it "fails" do
        expect(subject.test_results[:married_filing_joint_test]).to eq true
        expect(subject.qualifies?).to eq true
      end
    end
  end

  describe "financial_support_test" do
    let(:dependent) { create :qualifying_child, provided_over_half_own_support: provided_over_half_own_support }
    context "when providing over half support to dependent" do
      let(:provided_over_half_own_support) { "no" }
      it "passes" do
        expect(subject.test_results[:financial_support_test]).to eq true
        expect(subject.qualifies?).to eq true
      end
    end

    context "when person provides most of their own support" do
      let(:provided_over_half_own_support) { "yes" }
      it "disqualifies the dependent" do
        expect(subject.test_results[:financial_support_test]).to eq false
        expect(subject.qualifies?).to eq false
        expect(subject.disqualifiers).to eq [:financial_support_test]
      end
    end
  end

  describe "residence_test" do
    let(:dependent) { create :qualifying_child, birth_date: birth_date }
    context "when dependent was born in last 6 months of the tax year" do
      let(:birth_date) { Date.new(TaxReturn.current_tax_year, 7, 1) }
      it "returns true" do
        expect(subject.test_results[:residence_test]).to eq true
        expect(subject.qualifies?).to eq true
      end
    end

    context "when lived in the home for more than 6 months?" do
      let(:dependent) { create :qualifying_child, lived_with_more_than_six_months: "yes" }

      let(:birth_date) { Date.new(TaxReturn.current_tax_year + 10, 7, 1) }
      it "returns true" do
        expect(subject.test_results[:residence_test]).to eq true
        expect(subject.qualifies?).to eq true
      end
    end

    context "when did not live in the home for more than 6 months" do
      let(:dependent) { create :qualifying_child, lived_with_more_than_six_months: "no" }

      context "when doesnt have an exception set" do
        it "returns false" do
          expect(subject.test_results[:residence_test]).to eq false
          expect(subject.qualifies?).to eq false
        end
      end

      context "when there is a residence exception" do
        let(:dependent) { create :qualifying_child, lived_with_more_than_six_months: "no" }

        residence_exceptions = [:residence_exception_born, :residence_exception_passed_away, :residence_exception_adoption, :permanent_residence_with_client]
        residence_exceptions.each do |exception|
          context "when #{exception} is yes" do
            before do
              dependent.update_attribute(exception, "yes")
            end
            
            it "passes the test" do
              expect(subject.test_results[:residence_test]).to eq true
              expect(subject.qualifies?).to eq true
            end
          end
        end
      end
    end
  end
end