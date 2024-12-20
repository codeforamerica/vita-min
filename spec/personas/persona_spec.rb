require "rails_helper"

describe "personas", skip: "Skipping until new personas are validated by program" do
  let(:tax_year) { Rails.configuration.statefile_current_tax_year }

  context "az", required_schema: "az" do
    let(:state_code) { :az }

    context "johnny" do
      let(:persona_name) { "johnny" }
      it_behaves_like :persona
    end

    context "leslie" do
      let(:persona_name) { "leslie" }
      it_behaves_like :persona
    end

    context "martha" do
      let(:persona_name) { "martha" }
      it_behaves_like :persona
    end

    context "rory" do
      let(:persona_name) { "rory" }
      it_behaves_like :persona
    end
  end

  context "ny", required_schema: "ny" do
    let(:state_code) { :ny }

    context "javier" do
      let(:persona_name) { "javier" }
      it_behaves_like :persona
    end
  end
end
