require "thor"

class ZendeskCli < Thor
  desc "import_partner", "Adds a partner to db/vita_partners.yml and Zendesk"
  option :name, description: "Partner Name (e.g. United Way of North Texas)"
  option :source, description: "Source code for partner"
  def import_partner
    name = options[:name] || ask("Partner Name (e.g. United Way of North Texas)")

    importer = ZendeskCli::ImportPartner.new(name, options[:source])
    importer.find_or_create_partner
  end

  desc "import_users", "Imports users for a partner"
  option :csv_path, description: "Path to CSV of users from template spreadsheet", required: true
  def import_users
    ZendeskCli::ImportUsers
      .from_csv(options[:csv_path])
      .import_all
  end

  desc "list_inactive_users", "Outputs a list of inactive users from the Zendesk API"
  option :csv_path, description: "Output to CSV.", required: true
  def list_inactive_users
    ZendeskCli::ListInactiveUsers
      .new
      .list_inactive_users(output_path: options[:csv_path])
  end

  desc "remove_users", "Removes a list of users from Zendesk via API"
  option :csv_path, description: "Input CSV of users to remove.", required: true
  def remove_users
    ZendeskCli::RemoveUsers
      .new(csv_path: options[:csv_path])
      .remove_all
  end
end
