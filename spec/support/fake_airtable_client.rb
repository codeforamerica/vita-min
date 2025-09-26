class FakeAirtableClient
  cattr_accessor :organizations
  self.organizations = []

  def initialize(*_args)
  end

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

class FakeAirtableRecord
  attr_accessor :fields

  def initialize(fields:)
    @fields = fields
  end

  def [](key)
    @fields[key]
  end
end

class FakeAirtableRecordContext
  def initialize(table)
    @table = table
  end

  def all
    FakeAirtableClient.organizations
  end
end

class FakeAirtableOrganization
  def self.all
    FakeAirtableClient.organizations
  end

  def self.language_offerings
    all.each_with_object({}) do |record, hash|
      org_name = record["Organization Name"]
      languages = record["Language offerings"]
      hash[org_name] = parse_languages(languages) if org_name.present?
    end
  end

  def self.organization_data
    all.each_with_object({}) do |record, hash|
      org_name = record["Organization Name"]
      if org_name.present?
        hash[org_name] = {
          language_offerings: parse_languages(record["Language offerings"]),
        }
      end
    end
  end

  def self.add_record(org_name, languages, additional_fields = {})
    record = FakeAirtableRecord.new(
      fields: {
        "Organization Name" => org_name,
        "Language offerings" => languages
      }.merge(additional_fields)
    )
    FakeAirtableClient.organizations << record
    record
  end

  def self.reset!
    FakeAirtableClient.organizations = []
  end

  private

  def self.parse_languages(languages_field)
    return [] if languages_field.blank?

    if languages_field.is_a?(Array)
      languages_field
    elsif languages_field.is_a?(String)
      languages_field.split(',').map(&:strip)
    else
      []
    end
  end
end