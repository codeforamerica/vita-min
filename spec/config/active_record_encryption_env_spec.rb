# Guards the block at the bottom of config/application.rb that sources the Active Record
# encryption keys from ENV. It has already been dropped once in a merge conflict, and
# nothing else fails when it goes missing: the app silently falls back to the credentials file.
#
# config/environments/test.rb overwrites all three keys with 'test', so this can't be
# checked from inside the test process. Instead it loads only config/application.rb in a
# subprocess and reads the config before the environment file runs.
require "json"
require "open3"

RSpec.describe "Active Record encryption keys in config/application.rb" do
  let(:keys) do
    {
      "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY" => "primary_key",
      "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY" => "deterministic_key",
      "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT" => "key_derivation_salt",
    }
  end

  def encryption_config_with(env)
    script = <<~RUBY
      require "./config/application"
      settings = Rails.application.config.active_record.encryption
      puts JSON.generate(#{keys.values.inspect}.to_h { |key| [key, settings[key.to_sym]] })
    RUBY

    stdout, stderr, status = Open3.capture3(
      { "RAILS_ENV" => "test" }.merge(env),
      "bundle", "exec", "ruby", "-rjson", "-e", script,
      chdir: File.expand_path("../..", __dir__)
    )
    raise "loading config/application.rb failed:\n#{stderr}" unless status.success?

    JSON.parse(stdout.lines.last)
  end

  it "reads each key from ENV when it is set" do
    env = keys.keys.to_h { |name| [name, "from-env-#{name.downcase}"] }

    expect(encryption_config_with(env)).to eq(
      keys.to_h { |name, setting| [setting, "from-env-#{name.downcase}"] }
    )
  end

  it "leaves each key unset when ENV is blank, so the credentials file is used" do
    env = keys.keys.to_h { |name| [name, ""] }

    expect(encryption_config_with(env)).to eq(keys.values.to_h { |setting| [setting, nil] })
  end
end
