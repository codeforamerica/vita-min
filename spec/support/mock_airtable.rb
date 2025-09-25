module MockAirtable
  extend ActiveSupport::Concern

  included do
    before do
      # Replace the Airtable::Organization constant with our fake
      stub_const("Airtable::Organization", FakeAirtableOrganization)

      # Clear any records from previous tests
      FakeAirtableOrganization.reset!
    end
  end

  # Helper methods available in specs that include this module
  def add_airtable_organization(name, location)
    FakeAirtableOrganization.add_record(name, location)
  end

  def airtable_organizations
    FakeAirtableOrganization.records
  end
end