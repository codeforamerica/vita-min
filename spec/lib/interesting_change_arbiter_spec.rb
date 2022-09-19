require "rails_helper"

describe InterestingChangeArbiter do
  describe "#determine_changes" do
    context "when modifying an existing record" do
      let(:record) do
        u = create(:ctc_intake, primary_first_name: "William", primary_ip_pin: "123456")
        u.update(update_params)
        u
      end

      context "for a record with no changes" do
        let(:update_params) { {} }

        it "returns the empty hash" do
          expect(described_class.determine_changes(record)).to eq({})
        end
      end

      context "for a record with a changed field" do
        let(:update_params) { { primary_first_name: "Bill" } }
        it "returns a hash including the old & new value" do
          expect(described_class.determine_changes(record)).to eq({ "primary_first_name" => ["William", "Bill"] })
        end

        context "when changing an encrypted attribute" do
          let(:update_params) { { primary_ip_pin: "123457" } }
          it "redacts it" do
            expect(described_class.determine_changes(record)).to eq({ "primary_ip_pin" => ["[REDACTED]", "[REDACTED]"] })
          end
        end

        context "when changing a hashed attribute e.g. for duplicate checks" do
          let(:update_params) { { hashed_primary_ssn: "some_hashed_data" } }

          it "returns the empty hash" do
            expect(described_class.determine_changes(record)).to eq({})
          end
        end

        context "when changing a computed attribute within IGNORED_KEYS" do
          let(:update_params) { { email_domain: "example.com" } }

          it "returns the empty hash" do
            expect(described_class.determine_changes(record)).to eq({})
          end
        end

        context "with changing special noisy fields" do
          context "when changing from unfilled to no" do
            let(:update_params) { { was_blind: "no" } }

            it "returns the empty hash" do
              expect(described_class.determine_changes(record)).to eq({})
            end
          end

          context "when changing to yes" do
            let(:update_params) { { was_blind: "yes" } }

            it "returns the change" do
              expect(described_class.determine_changes(record)).to eq({ "was_blind" => ["unfilled", "yes"] })
            end
          end
        end
      end
    end
  end
end
