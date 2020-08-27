require 'csv'

class ZendeskCli
  class RemoveUsers
    include Thor::Shell

    def initialize(csv_path:)
      @csv_path = csv_path
    end

    def remove_all
      say "Loading agents..."
      agents = parse_csv(@csv_path)

      if yes?("  Delete #{agents.length} agents? [y/N]: ")
        agents.each do |agent_to_delete|
          begin
            say "Deleting #{agent_to_delete["email"]}..."
            agent = client.users.find(id: agent_to_delete["id"])
            if agent.destroy!
              say "  Deleted!"
            end
          rescue ZendeskAPI::Error::RecordInvalid => e
            say "  Could not delete #{agent_to_delete["email"]}: #{e.message}"
          end
        end
      end
    end

    def parse_csv(csv_path)
      contents = File.read(csv_path)
      CSV.parse(contents, headers: :first_row)
    end

    private

    def client
      @client ||= EitcZendeskInstance.client
    end
  end
end
