# Class containing logic related to the partner user CSV upload (see:
# app/cli/zendesk_cli/import_partners.rb).
class ZendeskUserCSVRow
  HEADERS = {
    first_name: 'User First Name',
    last_name: 'User Last Name',
    email: 'User Email',
    role: 'User Role',
    site_access: 'Site Access',
  }

  include ActiveModel::Model

  # Attributes from spreadsheet:
  attr_accessor :first_name, :last_name, :email, :role, :site_access

  validates :email, 'valid_email2/email': { mx: true }, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, inclusion: { in: ZendeskCli::ImportUsers::SPREADSHEET_ROLE_TO_ZENDESK_ROLE }, presence: true
  validates :site_access, presence: true

  def self.from_row(row)
    new(HEADERS.map { |attribute_name, header| [attribute_name, row[header]] }.to_h)
  end

  def self.to_row(**kwargs)
    CSV::Row.new(HEADERS.values, kwargs.values_at(*HEADERS.keys))
  end
end
