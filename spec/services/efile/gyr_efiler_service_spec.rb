require "rails_helper"

RSpec.describe Efile::GyrEfilerService do
  describe ".run_efiler_command" do
    before do
      allow(EnvironmentCredentials).to receive(:dig).with(:irs, :app_sys_id).and_return "asystemidiguess"
      allow(EnvironmentCredentials).to receive(:dig).with(:irs, :efile_cert_base64).and_return "somenumbersprobably"
      allow(EnvironmentCredentials).to receive(:dig).with(:irs, :etin).and_return "electronictransmitteridentificationnarwhal"
    end

    xcontext "success" do
      let(:zip_data) do
        buf = Zip::OutputStream.write_buffer do |zio|
          zio.put_next_entry("filename.txt")
          zio.write "File contents"
        end
        buf.seek(0)
        buf.string
      end

      before do
        allow(Process).to receive(:spawn) do |_argv, chdir:, unsetenv_others:, in:|
          File.open("#{chdir}/output/gyr-efiler-output.zip", 'wb') do |f|
            f.write(zip_data)
          end

          `true` # Run a successful command so that $? is set

          0 # Return a hypothetical process ID
        end

        allow(Process).to receive(:wait)
      end

      it "returns the file contents" do
        expect(described_class.run_efiler_command).to eq("File contents")
      end
    end

    xcontext "command failure" do
      before do
        allow(Process).to receive(:spawn) do |_argv, chdir:, unsetenv_others:, in:|
          File.open("#{chdir}/output/log/audit_log.txt", 'wb') do |f|
            f.write("Earlier line\nLogin Certificate: yikesdontsavethis\nLog output")
          end

          `false` # Run a command so that $? is set

          0 # Return a hypothetical process ID
        end

        allow(Process).to receive(:wait)
      end

      it "raises an exception with the log output, with Login Certificate line removed" do
        expect {
          described_class.run_efiler_command
        }.to raise_error(StandardError, "Earlier line\nLog output")
      end
    end
  end
end
