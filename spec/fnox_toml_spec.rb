# checks that Doppler Key names (never the values) in stg/prod/demo match fnox.toml
# talks to the Doppler API, so it skips unless the doppler CLI is installed and authenticated
require "json"
require "open3"

RSpec.describe "fnox.toml" do
  def fnox_path
    File.expand_path("../fnox.toml", __dir__)
  end

  def self.parse_fnox(text)
    section = nil
    provider = {}
    secrets = {}

    text.each_line do |raw_line|
      line = raw_line.strip
      next if line.empty? || line.start_with?("#")

      if (match = line.match(/\A\[(.+)\]\z/))
        section = match[1]
        next
      end

      case section
      when "providers.doppler"
        if (match = line.match(/\A(project|config)\s*=\s*['"]([^'"]+)['"]/))
          provider[match[1].to_sym] = match[2]
        end
      when "secrets"
        if (match = line.match(/\A([A-Za-z0-9_]+)\s*=\s*\{.*?value\s*=\s*['"]([^'"]+)['"]/))
          secrets[match[1]] = match[2]
        end
      end
    end

    { project: provider[:project], config: provider[:config], secrets: secrets }
  end

  let(:fnox) { self.class.parse_fnox(File.read(fnox_path)) }
  let(:doppler_names) { doppler_secret_names(fnox) }

  def doppler(fnox, *args)
    stdout, _stderr, status = Open3.capture3(
      "doppler", "secrets",
      "--project", fnox[:project], "--config", fnox[:config],
      "--json", *args
    )
    status.success? ? JSON.parse(stdout) : nil
  end

  def doppler_secret_names(fnox)
    return nil unless system("command -v doppler > /dev/null 2>&1")

    doppler(fnox, "--only-names")&.keys&.to_set
  end

  def blank_doppler_secret_names(fnox, names)
    values = doppler(fnox)
    return [] if values.nil?

    names
      .select { |name| values.key?(name) }
      .select { |name| values.dig(name, "computed").to_s.strip.empty? }
  end

  before do
    skip "doppler CLI is not installed or not authenticated" if doppler_names.nil?
  end

  it "declares the Doppler project and config it reads from" do
    expect(fnox[:project].to_s).not_to be_empty
    expect(fnox[:config].to_s).not_to be_empty
    expect(fnox[:secrets]).not_to be_empty
  end

  it "points every entry at a secret that exists in the Doppler config" do
    missing = fnox[:secrets]
      .reject { |_env_var, secret_name| doppler_names.include?(secret_name) }
      .map { |env_var, secret_name| "#{env_var} -> #{secret_name}" }

    expect(missing).to be_empty, <<~MESSAGE
      fnox.toml references Doppler secrets that do not exist in
      #{fnox[:project]}/#{fnox[:config]}, so these env vars will be unset locally:

        #{missing.join("\n  ")}

      Either add them to the Doppler config or remove the entries from fnox.toml.
    MESSAGE
  end

  it "resolves every entry to a non-empty value" do
    referenced = fnox[:secrets].values
    blank = blank_doppler_secret_names(fnox, referenced)

    expect(blank).to be_empty, <<~MESSAGE
      These Doppler secrets in #{fnox[:project]}/#{fnox[:config]} exist but are empty, so
      the matching env vars will be blank locally:

        #{blank.join("\n  ")}
    MESSAGE
  end
end
