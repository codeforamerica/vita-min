module MockAirtable
  extend ActiveSupport::Concern

  included do
    before do
      stub_const("Airtable::Organization", FakeAirtableOrganization)

      FakeAirtableOrganization.reset!
    end
  end

  def add_airtable_organization(name, location)
    FakeAirtableOrganization.add_record(name, location)
  end

  def airtable_organizations
    FakeAirtableOrganization.records
  end
end