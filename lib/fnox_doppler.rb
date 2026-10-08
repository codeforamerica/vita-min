require "json"
require "open3"

module FnoxDoppler
  DEV_ONLY_SECRETS = %w[PERCY_TOKEN].freeze

  module_function

  def fnox_path
    File.expand_path("../fnox.toml", __dir__)
  end

  def parse(text)
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

  def doppler_installed?
    system("command -v doppler > /dev/null 2>&1")
  end

  def secret_names(project, config)
    # returns nil when the doppler CLI is missing, unauthenticated, or can't read the config
    return nil unless doppler_installed?

    # names only (--only-names), so this never pulls secret values
    secrets_json(project, config, "--only-names")&.keys&.to_set
  end

  def blank_secret_names(project, config, names)
    # only use this against the doppler dev config b/c unlike secret_names, this downloads the value since doppler has no is blank method
    values = secrets_json(project, config)
    return [] if values.nil?

    names
      .select { |name| values.key?(name) }
      .select { |name| values.dig(name, "computed").to_s.strip.empty? }
  end

  def missing_entries(fnox, names, config: fnox[:config])
    fnox[:secrets]
      .reject { |_env_var, secret_name| names.include?(secret_name) }
      .reject { |_env_var, secret_name| config != fnox[:config] && DEV_ONLY_SECRETS.include?(secret_name) }
      .map { |env_var, secret_name| "#{env_var} -> #{secret_name}" }
  end

  def secrets_json(project, config, *args)
    stdout, _stderr, status = Open3.capture3(
      "doppler", "secrets",
      "--project", project, "--config", config,
      "--json", *args
    )
    status.success? ? JSON.parse(stdout) : nil
  end
end
