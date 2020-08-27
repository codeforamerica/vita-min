require 'csv'

class ZendeskCli
  class ListInactiveUsers
    include Thor::Shell

    # A user is "inactive" if they don't log in for this amount of time
    INACTIVE_THRESHOLD = 60.days

    # An "inactive" user will NOT be removed if their account is less than
    # this old:
    GRACE_PERIOD = 60.days

    # "Inactive" users will NOT be removed that are likely system users
    SKIP_EMAIL_REGEX = /getyourrefund\.org|codeforamerica\.org/.freeze

    # Headers for the CSV to export
    CSV_HEADERS = %w[id email name last_login_at default_group_id created_at].freeze

    def initialize; end

    def list_inactive_users(output_path: nil)
      puts "Loading agents..." unless Rails.env.test?
      puts "  Loaded #{agents.length} Zendesk users." unless Rails.env.test?
      puts "Exporting to #{output_path}..." unless Rails.env.test? if output_path.present?

      CSV.open(output_path, "w", write_headers: true, headers: CSV_HEADERS) do |csv|
        inactive_agents.each do |agent|
          csv << agent.values_at(*CSV_HEADERS)
        end
      end

      puts "  Exported #{inactive_agents.length} Zendesk users to remove." unless Rails.env.test?
    end

    def inactive_agents
      @inactive_agents ||= agents.find_all do |agent|
        (agent.last_login_at.nil? || agent.last_login_at < INACTIVE_THRESHOLD.ago) &&
          agent.created_at < GRACE_PERIOD.ago &&
          !SKIP_EMAIL_REGEX.match(agent.email)
      end
    end

    private

    def agents
      @agents ||= []
      return @agents if @agents.any?

      client.users.search(query: "role:agent").all! do |user|
        @agents << user
      end

      @agents
    end

    def client
      @client ||= EitcZendeskInstance.client
    end
  end
end
