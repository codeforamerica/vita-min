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

  no_commands do
    def load_rails_env!
      require File.expand_path('../config/environment', File.dirname(__FILE__))
    end
  end
end
