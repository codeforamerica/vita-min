# checks that the Doppler secrets fnox.toml points at exist and are non-empty in the dev
# config it reads from. bin/release separately checks prod by name (bin/check-fnox-doppler).
# talks to the Doppler API, so it skips unless the doppler CLI is installed and authenticated
require_relative "../lib/fnox_doppler"

RSpec.describe "fnox.toml" do
  let(:fnox) { FnoxDoppler.parse(File.read(FnoxDoppler.fnox_path)) }
  let(:doppler_names) { FnoxDoppler.secret_names(fnox[:project], fnox[:config]) }

  before do
    next unless doppler_names.nil?

    # set REQUIRE_DOPPLER_CHECK in CI so that this will fail loudly incase locally there is an expired/missing token
    unless ENV["REQUIRE_DOPPLER_CHECK"].to_s.empty?
      raise "REQUIRE_DOPPLER_CHECK is set, but the doppler CLI is missing or unauthenticated. " \
            "Check that the CLI installed and that DOPPLER_TOKEN is available to this job."
    end

    skip "doppler CLI is not installed or not authenticated"
  end

  it "declares the Doppler project and config it reads from" do
    expect(fnox[:project].to_s).not_to be_empty
    expect(fnox[:config].to_s).not_to be_empty
    expect(fnox[:secrets]).not_to be_empty
  end

  it "points every entry at a secret that exists in the Doppler config" do
    missing = FnoxDoppler.missing_entries(fnox, doppler_names)

    expect(missing).to be_empty, <<~MESSAGE
      fnox.toml references Doppler secrets that do not exist in
      #{fnox[:project]}/#{fnox[:config]}, so these env vars will be unset locally:

        #{missing.join("\n  ")}

      Either add them to the Doppler config or remove the entries from fnox.toml.
    MESSAGE
  end

  it "resolves every entry to a non-empty value" do
    blank = FnoxDoppler.blank_secret_names(fnox[:project], fnox[:config], fnox[:secrets].values)

    expect(blank).to be_empty, <<~MESSAGE
      These Doppler secrets in #{fnox[:project]}/#{fnox[:config]} exist but are empty, so
      the matching env vars will be blank locally:

        #{blank.join("\n  ")}
    MESSAGE
  end
end
