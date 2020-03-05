require "rails_helper"

RSpec.describe PublicPagesHelper do
  describe "#enable_online_intake?" do
    let(:env_vars) { {} }
    let(:source) { nil }

    before do
      # The controller that rspec sets up for helper specs doesn't have the
      # `source` method defined, so we define it via this mock:
      without_partial_double_verification do
        allow(controller).to receive(:source).and_return(source)
      end
      env_vars.each { |k, v| ENV[k] = v }
    end

    after do
      env_vars.keys.each { |k| ENV.delete(k) }
    end

    describe "when the ENABLE_ONLINE_INTAKE variable is set" do
      let(:env_vars) { { "ENABLE_ONLINE_INTAKE" => "true" } }

      it "returns true" do
        expect(helper.enable_online_intake?).to eq(true)
      end

      describe "when the session source is 'propel'" do
        let(:source) { "propel" }

        it "returns false" do
          expect(helper.enable_online_intake?).to eq(false)
        end
      end
    end
  end
end
