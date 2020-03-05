require "rails_helper"

RSpec.describe PublicPagesHelper do
  describe "#enable_online_intake?" do
    let(:rails_env) { 'production' }
    let(:env_vars) { {} }
    let(:source) { nil }

    before do
      allow(Rails).to receive(:env).and_return(rails_env.inquiry)
      allow(helper).to receive(:session).and_return(source: source)
      env_vars.each { |k, v| ENV[k] = v }
    end

    after do
      env_vars.keys.each { |k| ENV.delete(k) }
    end

    describe "when not in production" do
      let(:rails_env) { 'development' }

      it "returns true" do
        expect(helper.enable_online_intake?).to eq(true)
      end
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
