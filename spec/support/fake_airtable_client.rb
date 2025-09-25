class FakeAirtableClient
  # Store records like FakeTwilioClient stores messages
  cattr_accessor :organizations
  self.organizations = []

  def initialize(*_args)
  end

  # Mock the table access pattern
  def table(base_key, table_name)
    FakeAirtableTable.new(base_key, table_name, self)
  end
end

class FakeAirtableTable
  attr_accessor :base_key, :table_name, :client

  def initialize(base_key, table_name, client)
    @base_key = base_key
    @table_name = table_name
    @client = client
  end

  def records(*args)
    FakeAirtableRecordContext.new(self)
  end

  def all
    FakeAirtableClient.organizations
  end
end

class FakeAirtableOrganization
  def self.all
    FakeAirtableClient.organizations
  end

  def self.primary_locations
    all.each_with_object({}) do |record, hash|
      org_name = record["Organization Name"]
      primary_location = record["Primary location"]
      hash[org_name] = primary_location if org_name.present?
    end
  end
  
  def self.add_record(org_name, location)
    record = FakeAirtableRecord.new(
      fields: {
        "Organization Name" => org_name,
        "Primary location" => location
      }
    )
    FakeAirtableClient.organizations << record
    record
  end

  def self.reset!
    FakeAirtableClient.organizations = []
  end
end