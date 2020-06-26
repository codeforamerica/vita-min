require "rails_helper"

RSpec.describe ZendeskCli::ListInactiveUsers do
  describe "#inactive_agents" do
    let(:agent) do
      ZendeskAPI::User.new(
        nil,
        last_login_at: agent_last_login,
        created_at: agent_created_at,
        email: agent_email,
      )
    end
    let(:agent_email) { "vita-volunteer@example.org" }
    let(:agent_created_at) { described_class::GRACE_PERIOD.ago - 1.day }
    let(:agent_last_login) { described_class::INACTIVE_THRESHOLD.ago - 1.day }
    let(:instance) { described_class.new }

    before do
      allow(instance).to receive(:agents).and_return([agent])
    end

    context "with an inactive user" do
      it "includes that agent" do
        expect(instance.inactive_agents).to include(agent)
      end
    end

    context "with an inactive user that has never logged in" do
      let(:agent_last_login) { nil }

      it "includes the user" do
        expect(instance.inactive_agents).to include(agent)
      end
    end

    context "with a user that was recently created" do
      let(:agent_created_at) { described_class::GRACE_PERIOD.ago + 1.day }

      it "does not include that agent" do
        expect(instance.inactive_agents).to be_empty
      end

      context "when that user has never logged in" do
        let(:agent_last_login) { nil }

        it "does not include that agent" do
          expect(instance.inactive_agents).to be_empty
        end
      end
    end

    context "with a user matching the SKIP_EMAIL_REGEX" do
      let(:agent_email) { "zendesk-sms@hooks.getyourrefund.org" }

      it "does not include that agent" do
        expect(instance.inactive_agents).to be_empty
      end
    end

    context "given an agent has logged in recently" do
      let(:agent_last_login) { described_class::INACTIVE_THRESHOLD.ago + 1.day }

      it "does not include that agent" do
        expect(instance.inactive_agents).to be_empty
      end
    end
  end
end
