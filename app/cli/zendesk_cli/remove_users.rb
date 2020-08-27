require 'csv'

class ZendeskCli
  class RemoveUsers
    include Thor::Shell

    def initialize(csv_path:)
      @csv_path = csv_path
    end

    def remove_all
      puts "Loading agents..." unless Rails.env.test?
      agents = parse_csv(@csv_path)

      if yes?("  Delete #{agents.length} agents? [y/N]: ")
        agents.each do |agent_to_delete|
          begin
            puts "Deleting #{agent_to_delete["email"]}..." unless Rails.env.test?
            agent = client.users.find(id: agent_to_delete["id"])
            if agent.destroy!
              puts "  Deleted!" unless Rails.env.test?
            end
          rescue ZendeskAPI::Error::RecordInvalid => e
            puts "  Could not delete #{agent_to_delete["email"]}: #{e.message}" unless Rails.env.test?
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
