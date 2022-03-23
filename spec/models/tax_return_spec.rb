# == Schema Information
#
# Table name: tax_returns
#
#  id                  :bigint           not null, primary key
#  certification_level :integer
#  current_state       :string
#  filing_status       :integer
#  filing_status_note  :text
#  internal_efile      :boolean          default(FALSE), not null
#  is_ctc              :boolean          default(FALSE)
#  is_hsa              :boolean
#  primary_signature   :string
#  primary_signed_at   :datetime
#  primary_signed_ip   :inet
#  ready_for_prep_at   :datetime
#  service_type        :integer          default("online_intake")
#  spouse_signature    :string
#  spouse_signed_at    :datetime
#  spouse_signed_ip    :inet
#  status              :integer          default("intake_before_consent"), not null
#  year                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  assigned_user_id    :bigint
#  client_id           :bigint           not null
#
# Indexes
#
#  index_tax_returns_on_assigned_user_id    (assigned_user_id)
#  index_tax_returns_on_client_id           (client_id)
#  index_tax_returns_on_current_state       (current_state)
#  index_tax_returns_on_year_and_client_id  (year,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assigned_user_id => users.id)
#  fk_rails_...  (client_id => clients.id)
#
require "rails_helper"

describe TaxReturn do
  describe "validations" do
    let(:client) { create :client }

    it "does not allow multiple tax returns with the same year on the same client" do
      described_class.create(client: client, year: 2019)

      expect {
        described_class.create!(client: client, year: 2019)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "touch behavior" do
    context "when the tax return is updated" do
      it_behaves_like "an internal interaction" do
        let(:subject) { create :tax_return }
      end
    end
  end

  describe "#record_expected_payments!" do
    context "when the return is accepted" do
      let(:tax_return) { create :tax_return }
      let(:efile_submission) { create :efile_submission, :transmitted, tax_return: tax_return }

      before do
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip1_amount).and_return(1000)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip2_amount).and_return(1300)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount).and_return(2400)

        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:ctc_amount).and_return(2400)
      end

      it "creates an accepted_tax_return_analytics association" do
        expect {
          efile_submission.transition_to(:accepted)
        }.to change(AcceptedTaxReturnAnalytics, :count).by 1
        expect(tax_return.accepted_tax_return_analytics.advance_ctc_amount_cents).to eq 120000
        expect(tax_return.accepted_tax_return_analytics.refund_amount_cents).to eq 230000
        expect(tax_return.accepted_tax_return_analytics.eip3_amount_cents).to eq 240000
      end
    end

    context "when the return is any status other than accepted" do
      let(:tax_return) { create :tax_return, :file_rejected }

      it "raises an error to prevent the transition" do
        expect {
          tax_return.record_expected_payments!
        }.to raise_error(StandardError)
         .and not_change(AcceptedTaxReturnAnalytics, :count)
      end
    end
  end

  describe "translation keys" do
    context "english keys" do
      it "has a key for each tax_return status" do
        described_class.statuses.each_key do |status|
          expect(I18n.t("hub.tax_returns.status.#{status}")).not_to include("translation missing")
        end
      end
    end

    context "spanish" do
      around do |example|
        I18n.with_locale(:es) { example.run }
      end

      it "has a key for each tax_return status" do
        TaxReturnStateMachine.states.each do |status|
          expect(I18n.t("hub.tax_returns.status.#{status}")).not_to include("translation missing")
        end
      end
    end
  end

  describe "#advance_to" do
    let(:tax_return) { create :tax_return, status.to_sym }

    context "with a status that comes before the current status" do
      let(:status) { "intake_in_progress" }

      it "does not change the status" do
        expect do
          tax_return.advance_to(status)
        end.not_to change(tax_return, :status)
      end
    end

    context "with a status that comes after the current status" do
      let(:status) { "intake_in_progress" }
      let(:new_status) { "file_ready_to_file" }

      it "changes to the new status" do
        expect do
          tax_return.advance_to(new_status)
        end.to change(tax_return, :status).from(status).to new_status
      end
    end
  end

  describe "#primary_has_signed_8879?" do
    context "when primary_signed_at and primary_signed_ip are present" do
      let(:tax_return) { create :tax_return, primary_signed_at: DateTime.now, primary_signed_ip: IPAddr.new, primary_signature: "Primary Taxpayer" }
      it "returns true" do
        expect(tax_return.primary_has_signed_8879?).to be true
      end
    end

    context "when signed_at is empty" do
      let(:tax_return) { create :tax_return, primary_signed_at: nil, primary_signed_ip: IPAddr.new, primary_signature: "Primary Taxpayer" }

      it "returns false" do
        expect(tax_return.primary_has_signed_8879?).to be false
      end
    end

    context "when ip is empty" do
      let(:tax_return) { create :tax_return, primary_signed_at: DateTime.now, primary_signed_ip: nil, primary_signature: "Primary Taxpayer" }

      it "returns false" do
        expect(tax_return.primary_has_signed_8879?).to be false
      end
    end
  end

  describe "#spouse_has_signed_8879?" do
    context "when spouse_signed_at and spouse_signed_ip are present" do
      let(:tax_return) { create :tax_return, spouse_signed_at: DateTime.now, spouse_signed_ip: IPAddr.new, spouse_signature: "Spouse Name" }
      it "returns true" do
        expect(tax_return.spouse_has_signed_8879?).to be true
      end
    end

    context "when spouse_signed_at is empty" do
      let(:tax_return) { create :tax_return, spouse_signed_at: nil, spouse_signed_ip: IPAddr.new, spouse_signature: "Spouse Name" }

      it "returns false" do
        expect(tax_return.spouse_has_signed_8879?).to be false
      end
    end

    context "when ip is empty" do
      let(:tax_return) { create :tax_return, spouse_signed_at: DateTime.now, spouse_signed_ip: nil, spouse_signature: "Spouse Name" }

      it "returns false" do
        expect(tax_return.spouse_has_signed_8879?).to be false
      end
    end
  end

  describe "#filing_jointly?" do
    context "the associated client intake is not filing joint" do
      let(:client) { create :client, intake: (create :intake, filing_joint: "no") }
      let(:tax_return) {
        create :tax_return,
               client: client
      }
      it "returns false" do
        expect(tax_return.filing_jointly?).to eq false
      end
    end

    context "the associated client intake is filing joint" do
      let(:client) { create :client, intake: (create :intake, filing_joint: "yes") }
      let(:tax_return) {
        create :tax_return,
               client: client
      }
      it "returns true" do
        expect(tax_return.filing_jointly?).to eq true
      end
    end
  end

  describe "#ready_for_8879_signature?" do
    let(:tax_return) { create :tax_return }

    context "when signed 8879 already exists" do
      before do
        create :document,
               document_type: DocumentTypes::CompletedForm8879.key,
               tax_return: tax_return,
               client: tax_return.client,
               upload_path:  Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")
      end

      it "returns false" do
        expect(tax_return.ready_for_8879_signature?(TaxReturn::PRIMARY_SIGNATURE)).to eq false
      end
    end

    context "when uploaded 8879 does not exist" do
      it "return false" do
        expect(tax_return.ready_for_8879_signature?(TaxReturn::PRIMARY_SIGNATURE)).to eq false
      end
    end

    context "when unsigned 8879 already exists and signed 8879 does not exist" do
      before do
        create :document,
               document_type: DocumentTypes::UnsignedForm8879.key,
               tax_return: tax_return,
               client: tax_return.client,
               upload_path:  Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf"),
               created_at: DateTime.yesterday
      end

      context "checking for primary" do
        context "the primary hasn't signed yet" do
          it "returns true" do
            expect(tax_return.ready_for_8879_signature?(TaxReturn::PRIMARY_SIGNATURE)).to eq true
          end
        end

        context "when the primary has signed the tax return" do
          let(:tax_return) {
            create :tax_return,
                   primary_signature: "Bob Pineapple",
                   primary_signed_ip: "127.0.0.1",
                   primary_signed_at: DateTime.current
          }
          before do
            tax_return.unsigned_8879s.update(document_type: DocumentTypes::CompletedForm8879.key)
          end

          it "returns false" do
            expect(tax_return.ready_for_8879_signature?(TaxReturn::PRIMARY_SIGNATURE)).to eq false
          end
        end

        context "the primary has signed and there is an unsigned 8879 that the spouse needs to sign" do
          let(:tax_return) {
            create :tax_return,
                   primary_signature: "Bob Pineapple",
                   primary_signed_ip: "127.0.0.1",
                   primary_signed_at: DateTime.current
          }

          before do
            tax_return.client.intake.update!(filing_joint: "yes")
          end

          it "returns false for primary" do
            expect(tax_return.ready_for_8879_signature?(TaxReturn::PRIMARY_SIGNATURE)).to eq false
          end

          it "returns true for spouse" do
            expect(tax_return.ready_for_8879_signature?(TaxReturn::SPOUSE_SIGNATURE)).to eq true
          end
        end

        context "the spouse has signed and there is an unsigned 8879 that the primary needs to sign" do
          let(:tax_return) {
            create :tax_return,
                   spouse_signature: "Jane Pineapple",
                   spouse_signed_ip: "127.0.0.99",
                   spouse_signed_at: DateTime.current
          }

          before do
            tax_return.client.intake.update!(filing_joint: "yes")
          end

          it "returns false for spouse" do
            expect(tax_return.ready_for_8879_signature?(TaxReturn::SPOUSE_SIGNATURE)).to eq false
          end

          it "returns true for primary" do
            expect(tax_return.ready_for_8879_signature?(TaxReturn::PRIMARY_SIGNATURE)).to eq true
          end
        end
      end

      context "checking for spouse" do
        context "the spouse signature is not required for filing status" do
          let(:client) { create :client, intake: (create :intake, filing_joint: "no") }
          let(:spouse_not_required_tax_return) {
            create :tax_return,
                   client: client
          }
          before do
            create :document,
                   document_type: DocumentTypes::UnsignedForm8879.key,
                   tax_return: spouse_not_required_tax_return,
                   client: spouse_not_required_tax_return.client,
                   upload_path:  Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")
          end

          it "returns false" do
            expect(spouse_not_required_tax_return.ready_for_8879_signature?(TaxReturn::SPOUSE_SIGNATURE)).to eq false
          end
        end

        context "spouse signature is required and the spouse hasn't signed yet" do
          let(:client) { create :client, intake: (create :intake, filing_joint: "yes") }
          let(:tax_return) {
            create :tax_return,
                   client: client
          }
          it "returns true" do
            expect(tax_return.ready_for_8879_signature?(TaxReturn::SPOUSE_SIGNATURE)).to eq true
          end
        end

        context "the spouse has signed" do
          let(:spouse_signed_tax_return) {
            create :tax_return,
                   spouse_signature: "Jane Pineapple",
                   spouse_signed_ip: "127.0.0.99",
                   spouse_signed_at: DateTime.current
          }

          before do
            create :document,
                   document_type: DocumentTypes::UnsignedForm8879.key,
                   tax_return: spouse_signed_tax_return,
                   client: spouse_signed_tax_return.client,
                   upload_path:  Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")
          end

          it "returns false" do
            expect(spouse_signed_tax_return.ready_for_8879_signature?(TaxReturn::SPOUSE_SIGNATURE)).to eq false
          end
        end
      end
    end
  end

  describe "#completely_signed_8879?" do
    let(:filing_joint) { "no" }
    let(:intake) { create :intake, filing_joint: filing_joint }
    let(:tax_return) { create :tax_return, client: create(:client, intake: intake) }

    context "single filing" do
      context "primary signed" do
        before do
          allow(tax_return).to receive(:primary_has_signed_8879?).and_return(true)
        end

        it "returns true" do
          expect(tax_return.completely_signed_8879?).to eq true
        end
      end

      context "primary has not signed" do
        before do
          allow(tax_return).to receive(:primary_has_signed_8879?).and_return(false)
        end

        it "returns false" do
          expect(tax_return.completely_signed_8879?).to eq false
        end
      end
    end

    context "filing jointly" do
      let!(:filing_joint) { "yes" }

      context "primary and spouse signed 8879" do
        before do
          allow(tax_return).to receive(:primary_has_signed_8879?).and_return(true)
          allow(tax_return).to receive(:spouse_has_signed_8879?).and_return(true)
        end

        it "returns true" do
          expect(tax_return.completely_signed_8879?).to eq true
        end
      end

      context "only primary signed 8879" do
        before do
          allow(tax_return).to receive(:primary_has_signed_8879?).and_return(true)
          allow(tax_return).to receive(:spouse_has_signed_8879?).and_return(false)
        end

        it "returns false" do
          expect(tax_return.completely_signed_8879?).to eq false
        end
      end
    end
  end

  describe "#ready_to_file?" do
    context "not filing jointly" do
      let(:client) { create :client, intake: (create :intake, filing_joint: "no") }

      context "when the return has not been signed" do
        let(:tax_return) { create :tax_return, primary_signed_at: nil, primary_signed_ip: nil, primary_signature: nil, client: client }

        it "return false" do
          expect(tax_return.ready_to_file?).to eq false
        end
      end

      context "when the return has been signed" do
        let(:tax_return) { create :tax_return, primary_signed_at: DateTime.current, primary_signed_ip: "127.0.1.1", primary_signature: "Joe Crabapple", client: client }

        it "return false" do
          expect(tax_return.ready_to_file?).to eq true
        end
      end
    end

    context "filing jointly" do
      let(:client) { create :client, intake: (create :intake, filing_joint: "yes") }

      context "the return has not been signed by the primary or the spouse" do
        let(:tax_return) {
          create :tax_return,
                 primary_signed_at: nil, primary_signed_ip: nil, primary_signature: nil,
                 spouse_signed_at: nil, spouse_signed_ip: nil, spouse_signature: nil,
                 client: client
        }

        it "returns false" do
          expect(tax_return.ready_to_file?).to eq false
        end
      end

      context "the return has been signed by the primary but not the spouse" do
        let(:tax_return) {
          create :tax_return,
                 primary_signed_at: DateTime.current, primary_signed_ip: "127.0.2.1", primary_signature: "Jill Kiwi",
                 spouse_signed_at: nil, spouse_signed_ip: nil, spouse_signature: nil,
                 client: client
        }

        it "returns false" do
          expect(tax_return.ready_to_file?).to eq false
        end
      end

      context "the return has been signed by the spouse but not the primary" do
        let(:tax_return) {
          create :tax_return,
                 primary_signed_at: nil, primary_signed_ip: nil, primary_signature: nil,
                 spouse_signed_at: DateTime.current, spouse_signed_ip: "127.0.3.1", spouse_signature: "George Grapefruit",
                 client: client
        }

        it "returns false" do
          expect(tax_return.ready_to_file?).to eq false
        end
      end

      context "the return has been signed by both the primary and the spouse" do
        let(:tax_return) {
          create :tax_return,
                 primary_signed_at: DateTime.current, primary_signed_ip: "127.0.4.1", primary_signature: "Abe Apple",
                 spouse_signed_at: DateTime.current, spouse_signed_ip: "127.0.5.1", spouse_signature: "Beatrice Blueberry",
                 client: client
        }

        it "returns true" do
          expect(tax_return.ready_to_file?).to eq true
        end
      end
    end
  end

  describe "#unsigned_8879s" do
    subject { tax_return.unsigned_8879s }

    context "when an unsigned form 8879 exists for the tax return" do
      let(:tax_return) { create :tax_return, :ready_to_sign }
      it "returns form8879 unsigned document objects" do
        expect(subject.pluck(:document_type).uniq).to eq ["Form 8879 (Unsigned)"]
      end
    end

    context "when an unsigned form 8879 exists but it is archived" do
      let(:tax_return) { create :tax_return }
      before do
        create :document, :pdf, document_type: DocumentTypes::UnsignedForm8879.key, archived: true, tax_return: tax_return, client: tax_return.client
      end
      it "is empty" do
        expect(subject).to be_empty
      end
    end

    context "when unsigned 8879s do not exist" do
      let(:tax_return) { create :tax_return }

      it "is empty" do
        expect(subject).to be_empty
      end
    end
  end

  describe "#signed_8879s" do
    subject { tax_return.signed_8879s }

    context "when a signed form 8879 exists" do
      let(:tax_return) { create :tax_return, :ready_to_file_solo }
      it "returns the signed document objects" do
        expect(subject.pluck(:document_type).uniq).to eq ["Form 8879 (Signed)"]
      end
    end

    context "when a signed form 8879 exists but it is archived" do
      let(:tax_return) { create :tax_return }
      before do
        create :document, :pdf, document_type: DocumentTypes::CompletedForm8879.key, archived: true, tax_return: tax_return, client: tax_return.client
      end
      it "is empty" do
        expect(subject).to be_empty
      end
    end

    context "when a signed form 8879 does not exist" do
      let(:tax_return) { create :tax_return }
      it "returns nil" do
        expect(subject).to be_empty
      end
    end
  end

  describe "#final_tax_documents" do
    let(:tax_return) { create :tax_return }
    subject { tax_return.final_tax_documents }

    context "with final tax documents" do
      before do
        create :document, document_type: DocumentTypes::FinalTaxDocument, tax_return: tax_return, client: tax_return.client
        create :document, document_type: DocumentTypes::Other, tax_return: tax_return, client: tax_return.client
        create :document, document_type: DocumentTypes::Other, tax_return: tax_return, client: tax_return.client, archived: true
        create :document, document_type: DocumentTypes::FinalTaxDocument, tax_return: tax_return, client: tax_return.client
      end

      it "returns all documents of type DocumentTypes::FinalTaxDocument associated with the tax return that are not archived" do
        expect(tax_return.final_tax_documents.length).to eq 2
        expect(tax_return.final_tax_documents.map(&:document_type).uniq).to eq [DocumentTypes::FinalTaxDocument.key]
      end
    end

    context "with no final tax documents " do
      it "returns an empty array" do
        expect(subject).to eq []
      end
    end
  end

  describe "#sign_primary!" do
    let(:tax_return) { create :tax_return, :ready_to_sign }
    let(:fake_ip) { IPAddr.new }
    let(:document_service_double) { double }
    let(:client) { create :client, intake: (create :intake, primary_first_name: "Primary", primary_last_name: "Taxpayer", timezone: "Central Time (US & Canada)") }
    let(:tax_return) { create :tax_return, :intake_in_progress, year: 2019, client: client }

    before do
      allow(Sign8879Service).to receive(:create)
    end

    context "when we dont need a spouse signature and can create the 8879 document" do
      context "when the transaction is successful" do
        it "creates a signed document" do
          expect(Sign8879Service).to receive(:create).with(tax_return)

          tax_return.sign_primary!(fake_ip)
        end

        it "saves the primary_signed_at date, primary_signed_ip, and primary signature to the tax return" do
          expect { tax_return.sign_primary!(fake_ip) }.to change(tax_return, :primary_signed_at).and change(tax_return, :primary_signed_ip).to(fake_ip).and change(tax_return, :primary_signature).to("Primary Taxpayer")
        end

        it "updates the tax return's status to ready to file" do
          expect {
            tax_return.sign_primary!(fake_ip)
          }.to change(tax_return, :status).to("file_ready_to_file")
        end

        it "creates a system note" do
          expect(SystemNote::StatusChange).to receive(:generate!).with(tax_return: tax_return, old_status: "intake_in_progress", new_status: :file_ready_to_file)

          tax_return.sign_primary!(fake_ip)
        end

        it "returns true" do
          expect(tax_return.sign_primary!(fake_ip)).to eq true
        end
      end

      context "when document creation fails" do
        before do
          allow(Sign8879Service).to receive(:create).and_raise ActiveRecord::Rollback
        end

        it "does not update the other tax_return signature fields" do
          expect {
            begin
              tax_return.sign_primary!(fake_ip)
            rescue FailedToSignReturnError
            end
            tax_return.reload
          }.to not_change(tax_return, :primary_signed_at).and not_change(tax_return, :primary_signed_ip)
        end
      end

      context "when tax_return update fails" do
        before do
          allow(tax_return).to receive(:save!).and_raise ActiveRecord::Rollback
        end

        it "does not save the document" do
          expect {
            begin
              tax_return.sign_primary!(fake_ip)
            rescue FailedToSignReturnError
            end
            tax_return.reload
          }.to not_change(tax_return.documents, :count)
        end

        it "raises an exception" do
          expect {
            tax_return.sign_primary!(fake_ip)
          }.to raise_error(FailedToSignReturnError)
        end
      end
    end

    context "we're waiting on a spouse signature before we make the document" do
      before do
        tax_return.filing_status = "married_filing_jointly"
      end

      it "updates the tax_return with primary signature fields" do
        expect { tax_return.sign_primary!(fake_ip) }
          .to change(tax_return, :primary_signed_at)
          .and change(tax_return, :primary_signature)
          .and change(tax_return, :primary_signed_ip)
      end

      it "does not create a document, change tax return status, or set needs response" do
        expect(Sign8879Service).to_not receive(:create)

        expect { tax_return.sign_primary!(fake_ip) }
          .to not_change(tax_return, :status)
          .and not_change(tax_return.client, :flagged_at)
      end

      it "creates a system note" do
        expect {
          tax_return.sign_primary!(fake_ip)
        }.to change { SystemNote.count }.by(1)

        system_note = SystemNote.last
        expect(system_note.body).to eq "Primary taxpayer signed 2019 form 8879. Waiting on spouse of taxpayer to sign."
        expect(system_note.client).to eq tax_return.client
      end

      it "rolls back the transaction if the system note fails to save" do
        expect(SystemNote).to receive(:create!)

        tax_return.sign_primary!(fake_ip)
      end
    end

    context "the return is already signed" do
      context "the primary has already signed" do
        let(:tax_return) { create :tax_return, year: 2019, client: client, primary_signature: "Charles Clementine", primary_signed_ip: "127.0.10.1", primary_signed_at: DateTime.current }

        it "raises and error" do
          expect {
            tax_return.sign_primary!(fake_ip)
          }.to raise_error(AlreadySignedError)
        end
      end
    end
  end

  describe "#sign_spouse!" do
    let(:tax_return) { create :tax_return, :ready_to_sign }
    let(:fake_ip) { IPAddr.new }
    let(:document_service_double) { double }
    let(:client) {
      create :client,
             intake: (create :intake,
                             primary_first_name: "Primary",
                             primary_last_name: "Taxpayer",
                             spouse_first_name: "Spouse",
                             spouse_last_name: "Taxpayer"
                             )
    }

    before do
      allow(Sign8879Service).to receive(:create)
    end

    context "when the primary has already signed and we can create the 8879 document" do
      let(:tax_return) { create :tax_return, :intake_in_progress, year: 2019, client: client, primary_signature: "Primary Taxpayer", primary_signed_at: DateTime.current, primary_signed_ip: fake_ip }

      context "when the transaction is successful" do
        it "creates a signed document" do
          expect(Sign8879Service).to receive(:create).with(tax_return)

          tax_return.sign_spouse!(fake_ip)
        end

        it "saves the spouse_signed_at date, spouse_signed_ip and spouse_signature to the tax return" do
          expect {
            tax_return.sign_spouse!(fake_ip)
            tax_return.reload
          }.to change(tax_return, :spouse_signed_at).and change(tax_return, :spouse_signed_ip).to(fake_ip).and change(tax_return, :spouse_signature).to("Spouse Taxpayer")
        end

        it "updates the tax return's status to ready to file" do
          expect {
            tax_return.sign_spouse!(fake_ip)
          }.to change(tax_return, :status).to("file_ready_to_file")
        end

        it "creates a system note" do
          expect(SystemNote::StatusChange).to receive(:generate!).with(tax_return: tax_return, old_status: "intake_in_progress", new_status: :file_ready_to_file)

          tax_return.sign_spouse!(fake_ip)
        end

        it "returns true" do
          expect(tax_return.sign_spouse!(fake_ip)).to eq true
        end
      end

      context "when document creation fails" do
        before do
          allow(Sign8879Service).to receive(:create).and_raise ActiveRecord::Rollback
        end

        it "does not update the other tax_return signature fields" do
          expect {
            begin
              tax_return.sign_spouse!(fake_ip)
            rescue FailedToSignReturnError
            end
            tax_return.reload
          }.to not_change { tax_return }
        end
      end

      context "when tax_return update fails" do
        before do
          allow(tax_return).to receive(:save!).and_raise ActiveRecord::Rollback
        end

        it "raises an exception" do
          expect {
            tax_return.sign_spouse!(fake_ip)
          }.to raise_error(FailedToSignReturnError)
        end
      end
    end

    context "we're waiting on a primary signature before we make the document" do
      let(:tax_return) { create :tax_return, filing_status: "married_filing_jointly", year: 2019, client: client, primary_signature: nil, primary_signed_at: nil, primary_signed_ip: nil }

      it "updates the tax_return with spouse signature fields" do
        expect { tax_return.sign_spouse!(fake_ip) }
          .to change(tax_return, :spouse_signed_at)
                .and change(tax_return, :spouse_signature)
                       .and change(tax_return, :spouse_signed_ip)
      end

      it "does not create a document, change tax return status, or set flagged" do
        expect(Sign8879Service).to_not receive(:create)

        expect { tax_return.sign_spouse!(fake_ip) }.to not_change(tax_return, :status).and not_change(tax_return.client, :flagged?)
      end

      it "creates a system note" do
        expect {
          tax_return.sign_spouse!(fake_ip)
        }.to change { SystemNote.count }.by(1)

        system_note = SystemNote.last
        expect(system_note.body).to eq "Spouse of taxpayer signed 2019 form 8879. Waiting on primary taxpayer to sign."
        expect(system_note.client).to eq tax_return.client
      end

      it "rolls back the transaction if the system note fails to save" do
        expect(SystemNote).to receive(:create!)

        tax_return.sign_primary!(fake_ip)
      end
    end

    context "the return is already signed" do
      context "the spouse has already signed" do
        let(:tax_return) { create :tax_return, year: 2019, client: client, spouse_signature: "Charles Clementine", spouse_signed_ip: "127.0.10.1", spouse_signed_at: DateTime.current }

        it "raises and error" do
          expect {
            tax_return.sign_spouse!(fake_ip)
          }.to raise_error(AlreadySignedError)
        end
      end
    end
  end

  describe ".grouped_statuses" do
    let(:result) { TaxReturnStateMachine::STATES_BY_STAGE }

    it "returns a hash with all stage keys" do
      expect(result).to have_key("intake")
      expect(result).to have_key("prep")
      expect(result).to have_key("review")
      expect(result).to have_key("file")
    end

    it "includes all intake statuses except before consent" do
      expect(result["intake"].length).to eq 7
      expect(result["intake"]).not_to include "intake_before_consent"
    end

    it "includes all prep statuses" do
      expect(result["prep"].length).to eq 3
    end

    it "includes all review statuses" do
      expect(result["review"].length).to eq 5
    end

    it "includes all filed statuses" do
      expect(result["file"].length).to eq 9
    end
  end

  describe "experience survey" do

    context "when a TaxReturn is ctc and drop off" do
      let!(:tax_return) { create(:tax_return, is_ctc: true, service_type: "drop_off") }

      it "does not send the survey" do
        expect {
          tax_return.enqueue_experience_survey
        }.not_to have_enqueued_job(SendClientCompletionSurveyJob)
      end
    end

    context "when a TaxReturn is ctc and online intake" do
      let!(:tax_return) { create(:tax_return, is_ctc: true, service_type: "online_intake") }
      it "enqueues a job for tomorrow" do
        t = Time.utc(2021, 2, 11, 10, 5, 0)
        Timecop.freeze(t) do
          expect {
            tax_return.enqueue_experience_survey
          }.to have_enqueued_job(SendClientCtcExperienceSurveyJob).at(Time.utc(2021, 2, 11, 10, 5, 0) + 1.day).with(tax_return.client)
        end
      end
    end

    context "when a tax return is not ctc" do
      let!(:tax_return) { create(:tax_return, is_ctc: false) }

      it "sends the survey a day later" do
        t = Time.utc(2021, 2, 11, 10, 5, 0)
        Timecop.freeze(t) do
          expect {
            tax_return.enqueue_experience_survey
          }.to have_enqueued_job(SendClientCompletionSurveyJob).at(Time.utc(2021, 2, 11, 10, 5, 0) + 1.day).with(tax_return.client)
        end
      end
    end
  end

  describe "#ready_for_prep_at" do
    let(:tax_return) { create :tax_return, :intake_ready }

    context "when there is a tax return transition to read for prep" do
      let(:current_timestamp) { DateTime.new }
      before do
        allow_any_instance_of(TaxReturnTransition).to receive(:created_at).and_return(current_timestamp)
        tax_return.transition_to("prep_ready_for_prep")

      end
      it "returns the created at of the tax return transition" do
        expect(tax_return.ready_for_prep_at).to eq current_timestamp
      end
    end

    context "when there is no transition to ready for prep" do
      it "returns nil" do
        expect(tax_return.ready_for_prep_at).to eq nil
      end
    end
  end

  describe "filing_status_code" do
    let(:tax_return) { create :tax_return, filing_status: "single" }
    it "returns the integer corresponding to the enum string value" do
      expect(tax_return.filing_status_code).to eq 1
    end

    context "when filing status is nil" do
      let(:tax_return) { create :tax_return, filing_status: nil }

      it "returns nil" do
        expect(tax_return.filing_status_code).to be_nil
      end
    end
  end

  describe "#standard_deduction" do
    let(:tax_return) { create :tax_return, year: 2021, filing_status: :married_filing_jointly }
    before do
      allow(StandardDeduction).to receive(:for)
    end

    it "calls StandardDeduction with appropriate params" do
      tax_return.standard_deduction
      expect(StandardDeduction).to have_received(:for).with(tax_year: 2021, filing_status: "married_filing_jointly")
    end
  end

  describe ".filing_years" do
    before do
      allow(Rails.application.config).to receive(:current_tax_year).and_return 2021
    end

    it "provides an array of available filing years, which is the current tax year and three previous years" do
      expect(TaxReturn.filing_years).to eq [2021, 2020, 2019, 2018]
    end
  end

  describe ".backtax_years" do
    before do
      allow(Rails.application.config).to receive(:current_tax_year).and_return 2021
    end

    it "excludes the current filing year from backtaxes" do
      expect(TaxReturn.backtax_years).to eq [2020, 2019, 2018]
    end
  end
end
