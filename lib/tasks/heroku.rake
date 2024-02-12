class HerokuHostnameHelper
  SERVICE_TYPES = [:gyr, :ctc, :statefile].freeze

  def self.hostnames
    SERVICE_TYPES.map { |service_type| [service_type, MultiTenantService.new(service_type).host] }.to_h
  end

  def self.hostname_desc
    hostnames.map { |service_type, hostname| "#{service_type}_hostname=#{hostname}"}.join(' ')
  end
end

namespace :heroku do
  desc 'Heroku release task (runs on every code push; on review app creation, runs before postdeploy task)'
  task release: :environment do
    if ActiveRecord::Base.connection.schema_migration.table_exists?
      Rake::Task['db:migrate'].invoke
    else
      Rails.logger.info "Database not initialized, skipping database migration."
    end
  end

  task review_app_setup: :environment do
    # Create pr-*.getyourrefund-testing.org and ctc.pr-*.getyourrefund-testing.org
    #
    # Implementation based on https://medium.com/clutter-engineering/heroku-review-apps-with-custom-domains-8edfc0a2b153
    #
    # We store secrets in environment variables, rather than in Rails secrets, for maximum convenience with Heroku's
    # web interface for editing environment variables.
    require 'platform-api'
    require 'aws-sdk-route53'

    # Extract out "pr-<pull request ID>" from heroku runtime app variable; use as subdomain
    Rails.logger.info("Setting up Heroku review app DNS: #{HerokuHostnameHelper.hostname_desc}")

    # Add the hostnames as to the Heroku app.
    # To create this key, follow https://help.heroku.com/PBGP6IDE/how-should-i-generate-an-api-key-that-allows-me-to-use-the-heroku-platform-api
    heroku_client = PlatformAPI.connect_oauth(ENV["HEROKU_PLATFORM_KEY"])
    heroku_app_name = ENV["HEROKU_APP_NAME"]
    puts "this is the step that might fail:"
    HerokuHostnameHelper.hostnames.each do |_service_type, hostname|
      heroku_client.domain.create(heroku_app_name, hostname: hostname, sni_endpoint: nil)
    end
    Rails.logger.info("Created Heroku domains")

    # Add both to Route 53; route53 code example based on https://www.petekeen.net/lets-encrypt-without-certbot & https://blog.rocketinsights.com/heroku-review-apps/
    #
    # Use a AWS access key & secret that is specific to getyourrefund-testing.org DNS; see AWS IAM for username vita-min-heroku.
    route53_client = Aws::Route53::Client.new(
      access_key_id: ENV["HEROKU_DNS_AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["HEROKU_DNS_SECRET_ACCESS_KEY"],
      region: 'us-east-1',
    )
    HerokuHostnameHelper.hostnames.each do |_service_type, hostname|
      cname_target = heroku_client.domain.info(heroku_app_name, hostname)["cname"]
      Rails.logger.info("Setting up AWS with cname_target=#{cname_target} fully_qualified_domain=#{hostname}")

      route53_client.change_resource_record_sets(
        hosted_zone_id: 'Z07292202GQEWB2CT0FOE', # Hosted Zone ID for getyourrefund-testing.org in Route 53
        change_batch: {
          changes: [
            {
              action: 'UPSERT',
              resource_record_set: {
                name: hostname,
                type: 'CNAME',
                ttl: 300,
                resource_records: [
                  { value: cname_target }
                ]
              }
            }
          ]
        }
      )
    end

    # Enable HTTPS Automated Certificate Management on Heroku for the custom domain
    Rails.logger.info("Setting up Heroku app HTTPS")
    heroku_client.app.enable_acm(heroku_app_name)

    Rails.logger.info("Done setting up Heroku review app DNS")
  end

  task review_app_predestroy: :environment do
    # Delete this app's hostnames from Route 53
    Rails.logger.info("Deleting Route 53 DNS: #{HerokuHostnameHelper.hostname_desc}")

    heroku_app_name = ENV["HEROKU_APP_NAME"]
    heroku_client = PlatformAPI.connect_oauth(ENV["HEROKU_PLATFORM_KEY"])
    route53_client = Aws::Route53::Client.new(
      access_key_id: ENV["HEROKU_DNS_AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["HEROKU_DNS_SECRET_ACCESS_KEY"],
      region: 'us-east-1',
    )
    HerokuHostnameHelper.hostnames.each do |_service_type, hostname|
      cname_target = heroku_client.domain.info(heroku_app_name, hostname)["cname"]
      Rails.logger.info("Deleting AWS CNAME with cname_target=#{cname_target} fully_qualified_domain=#{hostname}")

      route53_client.change_resource_record_sets(
        hosted_zone_id: 'Z07292202GQEWB2CT0FOE', # Hosted Zone ID for getyourrefund-testing.org in Route 53
        change_batch: {
          changes: [
            {
              action: 'DELETE',
              resource_record_set: {
                name: hostname,
                type: 'CNAME',
                ttl: 300,
                resource_records: [
                  { value: cname_target }
                ]
              }
            }
          ]
        }
      )
    end

  end

  desc 'Heroku postdeploy task (runs once on review app creation, after release task)'
  task postdeploy: :environment do
    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:seed'].invoke
  end
end
