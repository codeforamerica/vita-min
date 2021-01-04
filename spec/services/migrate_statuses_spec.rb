require 'rails_helper'

describe MigrateStatuses do
  let!(:tax_return) { create :tax_return, status: status }

  context '201 (was prep_ready_for_call)' do
    let(:status) { 201 }
    it 'changes to 104 / intake_ready_for_call' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "intake_ready_for_call"
    end
  end

  context '104 (was intake_needs_more_information)' do
    let(:status) { 104 }
    it 'changes to 105 / intake_info_requested' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "intake_info_requested"
    end
  end

  context '106 (was intake_needs_assignment)' do
    let(:status) { 101 }
    # 106 no longer exists -- force it by updating the column directly
    before do
      tax_return.update_column(:status, 106)
      tax_return.save(validate: false)
    end

    it 'changes to 201 / ready_for_prep' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "prep_ready_for_prep"
    end
  end

  context '202 (was prep_needs_more_information)' do
    let(:status) { 202 }
    it 'changes to 203 / prep_info_requested' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "prep_info_requested"
    end
  end

  context '203 (was prep_preparing)' do
    let(:status) { 203 }
    it 'changes to 202 / prep_preparing' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "prep_preparing"
    end
  end

  context '204 (was prep_ready_for_qr)' do
    let(:status) { 101 }
    # 106 no longer exists -- force it by updating the column directly
    before do
      tax_return.update_column(:status, 204)
      tax_return.save(validate: false)
    end

    it 'changes to 301 / review_ready_for_review' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "review_ready_for_qr"
    end
  end

  context '302 (was Completed/Signature requested)' do
    let(:status) { 302 }
    it 'changes to 304 / review_signature_requested' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "review_signature_requested"
    end
  end

  context '303 (was Needs more information)' do
    let(:status) { 303 }
    it 'changes to 305 / review_info_requested' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "review_info_requested"
    end
  end

  context '401 (was closed)' do
    let(:status) { 401 }
    it 'changes to 406 / file_not_filing' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "file_not_filing"
    end
  end

  context '402 (was return signed)' do
    let(:status) { 402 }
    it 'changes to 401 / file_ready_to_file' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "file_ready_to_file"
    end
  end

  context '502 (was return signed)' do
    let(:status) { 101 }
    # 106 no longer exists -- force it by updating the column directly
    before do
      tax_return.update_column(:status, 502)
      tax_return.save(validate: false)
    end
    it 'changes to 402 / file_efiled' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "file_efiled"
    end
  end

  context '503 (was filed_by_mail)' do
    let(:status) { 101 }
    # 503 no longer exists -- force it by updating the column directly
    before do
      tax_return.update_column(:status, 503)
      tax_return.save(validate: false)
    end
    it 'changes to 403 / file_mailed' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "file_mailed"
    end
  end

  context '504 (was _rejected)' do
    let(:status) { 101 }
    # 503 no longer exists -- force it by updating the column directly
    before do
      tax_return.update_column(:status, 504)
      tax_return.save(validate: false)
    end
    it 'changes to 404 / file_rejected' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "file_rejected"
    end
  end

  context '505 (was _accepted)' do
    let(:status) { 101 }
    # 503 no longer exists -- force it by updating the column directly
    before do
      tax_return.update_column(:status, 505)
      tax_return.save(validate: false)
    end
    it 'changes to 404 / file_accepted' do
      MigrateStatuses.migrate_all
      tax_return.reload
      expect(tax_return.status).to eq "file_accepted"
    end
  end
end