require 'rails_helper'

describe 'delete_ctc_data:perform' do
  let(:drivers_license) { create(:drivers_license) }
  let!(:ctc_intake) { create(:ctc_intake, client: create(:ctc_client), primary_drivers_license: drivers_license) }
  let!(:ctc_document) { create(:document, intake: ctc_intake, client: ctc_intake.client) }
  let!(:ctc_client_interaction) { create(:client_interaction, client: ctc_intake.client) }
  let!(:ctc_experiment_participant) { create(:experiment_participant, record: ctc_intake) }
  let!(:archived_ctc_intake) { create(:archived_2021_ctc_intake) }
  let!(:ctc_signup) { create(:ctc_signup) }
  let!(:ctc_efile_error) { create(:efile_error, service_type: :ctc) }

  let!(:gyr_intake) { create(:intake, client: create(:client)) }
  let!(:gyr_client_interaction) { create(:client_interaction, client: gyr_intake.client) }
  let!(:gyr_is_ctc_tax_return) { create(:gyr_tax_return, client: gyr_intake.client, is_ctc: true) }
  let!(:state_file_efile_error) { create(:efile_error, service_type: :state_file) }

  # a ctc client who also has an archived gyr intake should be skipped not deleted
  let!(:mixed_client) do
    create(:ctc_client).tap do |client|
      create(:ctc_intake, client: client)
      create(:archived_2021_gyr_intake, client: client)
    end
  end

  before do
    Rake.application.rake_require "tasks/delete_ctc_data"
    allow(STDIN).to receive(:gets).and_return("YES\n")
  end

  around do |example|
    $stdout = StringIO.new
    example.run
  ensure
    $stdout = STDOUT
  end

  def run_task(mode)
    Rake::Task['delete_ctc_data:perform'].reenable
    Rake::Task['delete_ctc_data:perform'].execute(Rake::TaskArguments.new([:mode], [mode]))
  end

  context "in destructive mode" do
    it "deletes CTC clients and their associated records" do
      ctc_client_id = ctc_intake.client_id
      archived_ctc_client_id = archived_ctc_intake.client_id
      ctc_document_id = ctc_document.id

      run_task('destructive')

      expect(Client.where(id: [ctc_client_id, archived_ctc_client_id])).to be_empty
      expect(Intake::CtcIntake.where(id: ctc_intake.id)).to be_empty
      expect(Archived::Intake::CtcIntake2021.where(id: archived_ctc_intake.id)).to be_empty
      expect(DriversLicense.where(id: drivers_license.id)).to be_empty
      expect(ClientInteraction.where(id: ctc_client_interaction.id)).to be_empty
      expect(ExperimentParticipant.where(id: ctc_experiment_participant.id)).to be_empty
      expect(PaperTrail::Version.where(item_type: "Document", item_id: ctc_document_id)).to be_empty
      expect(CtcSignup.where(id: ctc_signup.id)).to be_empty
      expect(EfileError.where(id: ctc_efile_error.id)).to be_empty
    end

    it "leaves GYR data alone" do
      run_task('destructive')

      expect(gyr_intake.reload).to be_present
      expect(gyr_intake.client.reload).to be_present
      expect(gyr_client_interaction.reload).to be_present
      expect(gyr_is_ctc_tax_return.reload).to be_present
      expect(state_file_efile_error.reload).to be_present
    end

    it "skips CTC clients that also have a non-CTC intake" do
      run_task('destructive')

      expect(mixed_client.reload).to be_present
      expect(Intake::CtcIntake.where(client: mixed_client)).to exist
    end

    it "skips CTC clients that also have an intake with no type" do
      archived_ctc_client_with_untyped_intake = create(:archived_2021_ctc_intake).client
      untyped_intake = create(:intake, client: archived_ctc_client_with_untyped_intake)
      untyped_intake.update_columns(type: nil)

      ctc_client_with_untyped_archived_intake = create(:ctc_intake, client: create(:ctc_client)).client
      untyped_archived_intake = create(:archived_2021_gyr_intake, client: ctc_client_with_untyped_archived_intake)
      untyped_archived_intake.update_columns(type: nil)

      run_task('destructive')

      expect(Client.where(id: [archived_ctc_client_with_untyped_intake.id, ctc_client_with_untyped_archived_intake.id]).count).to eq(2)
      expect(Intake.where(id: untyped_intake.id)).to exist
      expect(Archived::Intake2021.where(id: untyped_archived_intake.id)).to exist
    end

    it "does not delete shared records linked to CTC clients" do
      user = create(:user)
      ctc_client = ctc_intake.client
      vita_partner = ctc_client.vita_partner
      ctc_tax_return = create(:tax_return, :ctc, client: ctc_client, assigned_user: user)
      gyr_tax_return = create(:gyr_tax_return, client: create(:intake).client, assigned_user: user)
      tax_return_selection = create(:tax_return_selection, tax_returns: [ctc_tax_return, gyr_tax_return])
      create(:system_note, client: ctc_client, user: user)

      run_task('destructive')

      expect(TaxReturn.where(id: ctc_tax_return.id)).to be_empty
      expect(user.reload).to be_present
      expect(VitaPartner.where(id: [vita_partner.id, vita_partner.parent_organization_id]).count).to eq(2)
      expect(tax_return_selection.reload.tax_returns).to contain_exactly(gyr_tax_return)
      expect(gyr_tax_return.reload.assigned_user).to eq(user)
    end

    it "deletes CTC portal system notes" do
      ctc_portal_action = SystemNote::CtcPortalAction.create!(client: mixed_client, body: "action")
      ctc_portal_update = SystemNote::CtcPortalUpdate.create!(client: mixed_client, body: "update")

      run_task('destructive')

      expect(SystemNote.where(id: [ctc_portal_action.id, ctc_portal_update.id])).to be_empty
    end

    context "with GYR and state file records of every kind the task deletes" do
      let(:gyr_client) { gyr_intake.client }
      let(:gyr_drivers_license) { create(:drivers_license) }
      let!(:gyr_document) { create(:document, intake: gyr_intake, client: gyr_client) }
      let!(:gyr_experiment_participant) { create(:experiment_participant, record: gyr_intake) }
      let!(:gyr_system_note) { create(:system_note, client: gyr_client) }
      let!(:gyr_deleted_document_version_ids) do
        create(:document, intake: gyr_intake, client: gyr_client).destroy!
        PaperTrail::Version.where(item_type: "Document").pluck(:id)
      end
      let!(:archived_gyr_intake) { create(:archived_2021_gyr_intake) }

      # The reverse of mixed_client: a current GYR intake plus an archived CTC 2021 intake.
      let!(:gyr_client_with_archived_ctc_intake) do
        create(:client).tap do |client|
          create(:intake, client: client)
          create(:archived_2021_ctc_intake, client: client)
        end
      end

      let!(:state_file_intake) { create(:state_file_az_intake) }
      let!(:state_file_submission) { create(:efile_submission, :for_state, data_source: state_file_intake) }

      before do
        gyr_intake.update_columns(primary_drivers_license_id: gyr_drivers_license.id)
      end

      it "leaves all of them alone" do
        run_task('destructive')

        expect(gyr_client.reload).to be_present
        expect(gyr_document.reload).to be_present
        expect(gyr_experiment_participant.reload).to be_present
        expect(gyr_system_note.reload).to be_present
        expect(gyr_drivers_license.reload).to be_present
        expect(PaperTrail::Version.where(id: gyr_deleted_document_version_ids).count).to eq(gyr_deleted_document_version_ids.length)
        expect(archived_gyr_intake.reload).to be_present
        expect(archived_gyr_intake.client.reload).to be_present
        expect(gyr_client_with_archived_ctc_intake.reload.intake).to be_present
        expect(state_file_intake.reload).to be_present
        expect(state_file_submission.reload).to be_present
      end
    end
  end

  context "in dry run mode" do
    it "deletes nothing" do
      expect { run_task('dry_run') }.not_to change {
        [Client.count, Intake.count, Archived::Intake2021.count, DriversLicense.count, ClientInteraction.count,
         ExperimentParticipant.count, CtcSignup.count, EfileError.count, TaxReturn.count]
      }
    end
  end
end
