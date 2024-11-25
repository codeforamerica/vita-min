require 'thor'

class GyrCli < Thor
  desc "credentials_diff", "Shows a diff of the encrypted credentials"
  options environment: :string
  options base: :string

  def credentials_diff
    load_rails_env!

    base_branch = options[:base] || 'HEAD'
    puts "\e[35m>>> Printing credentials diff with base branch #{base_branch} <<<\e[0m\n"

    environments = options[:environment] ? [options[:environment]] : %w(production staging demo heroku development)
    environments.each do |environment|
      puts "\e[35mEnvironment: #{environment}\e[0m"
      content_path = "config/credentials/#{environment}.yml.enc"
      key_path = "config/credentials/#{environment}.key"

      unless File.exist?(key_path)
        puts "key does not exist at #{key_path}"
        next
      end

      old_content_file = Tempfile.new(["old_#{environment}", ".yml.enc"])
      system("git show #{base_branch}:#{content_path} > #{old_content_file.path}")

      new_decrypted = decrypt_to_file(key_path, content_path)
      old_decrypted = decrypt_to_file(key_path, old_content_file.path)

      system("git --no-pager diff #{old_decrypted.path} #{new_decrypted.path}")
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      next
    ensure
      puts
    end
  end

  desc "download_webdriver", "Downloads the latest chromedriver using SeleniumManager from the selenium-webdriver gem"
  def download_webdriver
    require 'selenium-webdriver'

    options = Selenium::WebDriver::Chrome::Options.new
    Selenium::WebDriver.for :chrome, options: options
  end

  no_commands do
    def load_rails_env!
      require File.expand_path('../config/environment', File.dirname(__FILE__))
    end

    def decrypt_to_file(key_path, credentials_path)
      credentials = Rails.application.encrypted(credentials_path, key_path: key_path)
      decrypted = Tempfile.new
      decrypted.write(credentials.read)
      decrypted.flush
      decrypted
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      puts "Unable to decrypt #{credentials_path} with #{key_path}"
      raise
    end
  end
end
