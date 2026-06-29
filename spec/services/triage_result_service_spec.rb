require "rails_helper"

RSpec.describe TriageResultService do
  subject(:route) do
    described_class.new(intake).after_household_triaged_route
  end

  let(:intake) do
    build(
      :intake,
      state_of_residence: "CO",
      locale: "en",
      triage_filing_status: "single",
      triage_income_level: "zero",
      triage_vita_income_ineligible: "no",
      service_preference: "virtual_vita",
      have_income_tax_documents: "yes",
      had_qualifying_child_under_17: "yes",
      had_qualifying_child_under_6: "unfilled",
      had_self_employment_income: "no",
      multiple_states: "no",
      had_rental_income: "no",
      had_farm_income: "no",
      has_crypto_income: false
    )
  end

  let(:simple_file_url) do
    "https://staging.simplefile.getyourrefund.org/en/service-selection/recommendation/simplefile?source=gyrsel&state_code=co"
  end

  let(:simple_file_url_service) do
    instance_double(SimpleFileUrlService, url: simple_file_url)
  end

  let(:diy_path) { "/en/questions/triage-diy" }
  let(:gyr_path) { "/en/questions/triage-gyr" }
  let(:offboarding_path) { "/en/questions/triage-offboarding" }

  before do
    allow(SimpleFileUrlService).to receive(:new).with(intake: intake, locale: intake.locale, source: "gyrsel").and_return(simple_file_url_service)
    allow(Questions::TriageDiyController).to receive(:to_path_helper).and_return(diy_path)
    allow(Questions::TriageGyrController).to receive(:to_path_helper).and_return(gyr_path)
    allow(Questions::TriageOffboardingController).to receive(:to_path_helper).and_return(offboarding_path)
  end

  describe "#after_household_triaged_route" do
    describe "simple file routing" do
      context "when a CO client is eligible and has zero income" do
        it "routes to Simple File" do
          expect(route).to eq(simple_file_url)
        end

        it "builds the url with the intake locale and gyrsel (flow) source" do
          described_class.new(intake).after_household_triaged_route
          expect(SimpleFileUrlService).to have_received(:new).with(intake: intake, locale: "en", source: "gyrsel")
        end
      end

      context "when an eligible client selected none of the disqualifying income scenarios" do
        before do
          intake.triage_income_level = "1_to_10000"
          intake.triage_vita_income_ineligible = "yes"
        end

        it "routes to simple file" do
          expect(route).to eq(simple_file_url)
        end
      end

      context "when an eligible client does not have their income documents" do
        before do
          intake.triage_income_level = "1_to_10000"
          intake.have_income_tax_documents = "no"
        end

        it "routes to simpleFile" do
          expect(route).to eq(simple_file_url)
        end
      end

      context "when the client is eligible but no priority condition applies" do
        before do
          intake.triage_income_level = "1_to_10000"
          intake.triage_vita_income_ineligible = "no"
          intake.have_income_tax_documents = "yes"
        end

        it "uses the existing routing logic" do
          expect(route).to eq(gyr_path)
        end

        it "does not build a simple file url" do
          described_class.new(intake).after_household_triaged_route

          expect(SimpleFileUrlService).not_to have_received(:new)
        end
      end

      context "when the client lives in NJ" do
        before do
          intake.state_of_residence = "NJ"
          intake.triage_filing_status = "single"
          intake.triage_income_level = "zero"
          intake.had_qualifying_child_under_17 = "unfilled"
          intake.had_qualifying_child_under_6 = "yes"
        end

        it "routes to simple file" do
          expect(route).to eq(simple_file_url)
        end
      end
    end

    describe "simple file state eligibility" do
      context "when the client does not live in CO or NJ" do
        before do
          intake.state_of_residence = "NY"
        end

        it "uses the existing routing logic and does not route to simple file" do
          expect(route).to eq(gyr_path)
        end
      end
    end

    describe "simple file income eligibility" do
      context "for a single Colorado filer" do
        it "is eligible at $10,001–$15,000" do
          intake.triage_income_level = "10001_to_15000"
          intake.have_income_tax_documents = "no"

          expect(route).to eq(simple_file_url)
        end

        it "is ineligible above $15,000" do
          intake.triage_income_level = "15001_to_20000"
          intake.have_income_tax_documents = "no"

          expect(route).to eq(gyr_path)
        end
      end

      context "for a jointly filing CO client" do
        before do
          intake.triage_filing_status = "jointly"
          intake.have_income_tax_documents = "no"
        end

        it "is eligible for income between $15,001 and 20,000" do
          intake.triage_income_level = "15001_to_20000"

          expect(route).to eq(simple_file_url)
        end

        it "is eligible in the $20,001–26,000 range" do
          intake.triage_income_level = "20001_to_26000"

          expect(route).to eq(simple_file_url)
        end

        it "is ineligible in the $26,001 to 69,000 range" do
          intake.triage_income_level = "26001_to_69000"

          expect(route).to eq(gyr_path)
        end
      end

      context "for a single New Jersey filer" do
        before do
          intake.state_of_residence = "NJ"
          intake.triage_filing_status = "single"
          intake.had_qualifying_child_under_17 = "unfilled"
          intake.had_qualifying_child_under_6 = "yes"
          intake.have_income_tax_documents = "no"
        end

        it "is eligible at $1–$10,000" do
          intake.triage_income_level = "1_to_10000"

          expect(route).to eq(simple_file_url)
        end

        it "is ineligible above $10,000" do
          intake.triage_income_level = "10001_to_15000"

          expect(route).to eq(gyr_path)
        end
      end

      context "for a jointly filing New Jersey client" do
        before do
          intake.state_of_residence = "NJ"
          intake.triage_filing_status = "jointly"
          intake.had_qualifying_child_under_17 = "unfilled"
          intake.had_qualifying_child_under_6 = "yes"
          intake.have_income_tax_documents = "no"
        end

        it "is eligible at $15,001–$20,000" do
          intake.triage_income_level = "15001_to_20000"

          expect(route).to eq(simple_file_url)
        end

        it "is ineligible above $20,000" do
          intake.triage_income_level = "20001_to_26000"

          expect(route).to eq(gyr_path)
        end
      end

      context "when the filing status is unsupported" do
        before do
          intake.triage_filing_status = "unfilled"
        end

        it "uses the existing routing logic" do
          expect(route).to eq(gyr_path)
        end
      end
    end

    describe "simple-file income type eligibility" do
      [
        [:had_self_employment_income, "yes"],
        [:multiple_states, "yes"],
        [:had_rental_income, "yes"],
        [:had_farm_income, "yes"],
        [:has_crypto_income, true]
      ].each do |attribute, disqualifying_value|
        context "when #{attribute} is #{disqualifying_value.inspect}" do
          before do
            intake.public_send("#{attribute}=", disqualifying_value)
          end

          it "does not route to simple file" do
            expect(route).to eq(gyr_path)
          end
        end
      end
    end

    describe "simpleFile qualifying child eligibility" do
      context "for Colorado" do
        context "when the client answers no" do
          before do
            intake.had_qualifying_child_under_17 = "no"
          end

          it "does not route to SimpleFile" do
            expect(route).to eq(gyr_path)
          end
        end

        context "when the answer is unfilled" do
          before do
            intake.had_qualifying_child_under_17 = "unfilled"
          end

          it "does not route to simpleFile" do
            expect(route).to eq(gyr_path)
          end
        end
      end

      context "for New Jersey" do
        before do
          intake.state_of_residence = "NJ"
          intake.had_qualifying_child_under_17 = "unfilled"
          intake.had_qualifying_child_under_6 = "no"
        end

        it "does not route to simple file" do
          expect(route).to eq(gyr_path)
        end
      end
    end

    describe "existing routing behavior" do
      before do
        intake.state_of_residence = "NY"
      end

      context "with zero income and a DIY preference" do
        before do
          intake.triage_income_level = "zero"
          intake.service_preference = "diy"
        end

        it "routes to DIY" do
          expect(route).to eq(diy_path)
        end
      end

      context "with income between $1 and $69,000" do
        before do
          intake.triage_income_level = "26001_to_69000"
        end

        context "when VITA income scenarios are ineligible" do
          before do
            intake.triage_vita_income_ineligible = "yes"
          end

          it "routes to DIY" do
            expect(route).to eq(diy_path)
          end
        end

        context "when the client prefers DIY" do
          before do
            intake.service_preference = "diy"
          end

          it "routes to DIY" do
            expect(route).to eq(diy_path)
          end
        end

        context "when neither DIY condition applies" do
          before do
            intake.triage_vita_income_ineligible = "no"
            intake.service_preference = "virtual_vita"
          end

          it "routes to GYR" do
            expect(route).to eq(gyr_path)
          end
        end
      end

      context "with income between $69,001 and $89,000" do
        before do
          intake.triage_income_level = "69001_to_89000"
        end

        context "when VITA income scenarios are ineligible" do
          before do
            intake.triage_vita_income_ineligible = "yes"
          end

          it "routes to DIY" do
            expect(route).to eq(diy_path)
          end
        end

        context "when no DIY condition applies" do
          before do
            intake.triage_vita_income_ineligible = "no"
            intake.service_preference = "virtual_vita"
          end

          it "routes to GYR" do
            expect(route).to eq(gyr_path)
          end
        end
      end

      context "with income over $89,000" do
        before do
          intake.triage_income_level = "over_89000"
        end

        context "when VITA income scenarios are ineligible" do
          before do
            intake.triage_vita_income_ineligible = "yes"
          end

          it "routes to offboarding" do
            expect(route).to eq(offboarding_path)
          end
        end

        context "when VITA income scenarios are not ineligible" do
          before do
            intake.triage_vita_income_ineligible = "no"
          end

          it "routes to GYR" do
            expect(route).to eq(gyr_path)
          end
        end
      end
    end
  end
end