require "rails_helper"

RSpec.feature "Logging in and out to the volunteer portal" do
  let(:successful_update) { create :tax_return }
  let(:failed_update) { create :tax_return }
  let(:another_failed_update) { create :tax_return }
  let!(:bulk_edit) { BulkEdit.generate!(user: (create :user), record_type: TaxReturn, successful_ids: [successful_update.id], failed_ids: [failed_update.id, another_failed_update.id])}
  before do
    login_as (create :admin_user)
  end

  scenario "viewing an existing bulk edit" do
    visit "/en/hub/clients?bulk_edit=#{bulk_edit.id}"
    expect(page).to have_text "Displaying all 3 clients from your saved search"
    expect(page.all('.client-row').length).to eq 3

    visit "/en/hub/clients?bulk_edit=#{bulk_edit.id}&only=successful"
    expect(page).to have_text "Displaying 1 client from your saved search"
    expect(page.all('.client-row').length).to eq 1
    expect(page.all('.client-row')[0]).to have_text(successful_update.client.id)

    visit "/en/hub/clients?bulk_edit=#{bulk_edit.id}&only=failed"
    expect(page).to have_text "Displaying all 2 clients from your saved search"
    expect(page.all('.client-row').length).to eq 2
    expect(page.all('.client-row')[0]).to have_text(failed_update.client.id)
  end

end