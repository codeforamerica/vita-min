require 'thor'

class GyrCli < Thor
  desc "credentials_diff", "Shows a diff of the encrypted credentials"
  options environment: :string

  def credentials_diff
    load_rails_env!

    content_path = "config/credentials/#{options[:environment]}.yml.enc"
    key_path = "config/credentials/#{options[:environment]}.key"

    old_content_file = Tempfile.new
    system("git show HEAD:#{content_path} > #{old_content_file.path}")

    old_credentials = Rails.application.encrypted(old_content_file.path, key_path: key_path)
    new_credentials = Rails.application.encrypted(content_path, key_path: key_path)

    old_decrypted = Tempfile.new
    old_decrypted.write(old_credentials.read)
    old_decrypted.flush

    new_decrypted = Tempfile.new
    new_decrypted.write(new_credentials.read)
    new_decrypted.flush

    system("git --no-pager diff #{old_decrypted.path} #{new_decrypted.path}")
  end

  desc "test_capacity_algorithms", "Compare capacity calculations before and after cte refactor"
  def test_capacity_algorithms
    load_rails_env!

    user = User.find_by(role_type: 'AdminRole')

    old_org_presenter = Hub::OrganizationsPresenter.new(Ability.new(user), capacity_algorithm: :view)

    new_org_presenter = Hub::OrganizationsPresenter.new(Ability.new(user), capacity_algorithm: :cte)

    all_results = []
    [
      CapacityTestCase.new("old", old_org_presenter),
      CapacityTestCase.new("new", new_org_presenter)
    ].each do |test_case|
      org_presenter = test_case.presenter

      results = {'UNROUTED' => {}}
      time_took = Benchmark.realtime do
        States.hash.each do |abbreviation, full|
          results[abbreviation] = {}

          (org_presenter.accessible_entities_for(abbreviation) || []).each do |entity|
            orgs = entity.is_a?(Coalition) ? org_presenter.organizations_in_coalition(entity) : [entity]

            orgs.each do |org|
              results[abbreviation][org.id] = {name: org.name, capacity: org_presenter.organization_capacity(org)}
            end
          end
        end

        org_presenter.unrouted_independent_organizations.each do |org|
          results['UNROUTED'][org.id] = {name: org.name, capacity: org_presenter.organization_capacity(org)}
        end

        org_presenter.unrouted_coalitions.each do |coalition|
          org_presenter.organizations_in_coalition(coalition).each do |org|
            results['UNROUTED'][org.id] = {name: org.name, capacity: org_presenter.organization_capacity(org)}
          end
        end

        results.each do |state_or_unrouted, orgs_and_capacities|
          orgs_and_capacities.each do |org_id, data|
            # puts "#{org_id} #{data[:name]} #{data[:capacity].current_count} / #{data[:capacity].total_capacity}"
          end
        end
      end

      puts "'#{test_case.name}' total time: #{time_took}"
      all_results << results
      puts
    end
    puts "Did capacity calculations match? #{all_results[0] == all_results[1]}"

    all_results = []
    intake = OpenStruct.new(itin_applicant?: false, probable_previous_year_intake: nil)
    random_zip_codes = ZipCodes.send(:zip_codes).keys.sample(100)
    [:view, :cte].each do |capacity_algorithm|
      results = {}
      time_took = Benchmark.realtime do
        random_zip_codes.each do |code|
          s = PartnerRoutingService.new(intake: intake, zip_code: code, capacity_algorithm: capacity_algorithm)
          results[code] = s.determine_partner
        end
      end
      puts "routing '#{capacity_algorithm}' total time: #{time_took}"
      all_results << results
    end
    puts "Did partner routes match? #{all_results[0] == all_results[1]}"
  end

  no_commands do
    def load_rails_env!
      require File.expand_path('../config/environment', File.dirname(__FILE__))
    end
  end

  CapacityTestCase = Struct.new(:name, :presenter)
end
