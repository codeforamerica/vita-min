require "rails_helper"

RSpec.describe Efile::GyrEfilerService do
  before do
    # Skip preparing & downloading gyr-efiler since we mock `Process.spawn()` anyway.
    allow(described_class).to receive(:ensure_config_dir_prepared)
    allow(described_class).to receive(:ensure_gyr_efiler_downloaded).and_return("/tmp/hypothetical_classes.zip")
  end

  describe ".run_efiler_command" do
    before do
      allow(EnvironmentCredentials).to receive(:dig).with(:irs, :app_sys_id).and_return "asystemidiguess"
      allow(EnvironmentCredentials).to receive(:dig).with(:irs, :efile_cert_base64).and_return "somenumbersprobably"
      allow(EnvironmentCredentials).to receive(:dig).with(:irs, :etin).and_return "electronictransmitteridentificationnarwhal"
    end

    context "success" do
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

    context "command failure" do

      before do
        allow(Process).to receive(:spawn) do |_argv, chdir:, unsetenv_others:, in:|
          File.open("#{chdir}/output/log/audit_log.txt", 'wb') do |f|
            f.write(log_output)
          end

          `false` # Run a command so that $? is set

          0 # Return a hypothetical process ID
        end

        allow(Process).to receive(:wait)
      end

      context "for unknown errors" do
        let(:log_output) { "Earlier line\nLogin Certificate: blahBlahBlah\nLog output" }

        it "raises an exception with the log output" do
          expect {
            described_class.run_efiler_command
          }.to raise_error(StandardError, "Earlier line\nLogin Certificate: blahBlahBlah\nLog output")
        end
      end

      context "when the cause is a gyr-efiler socket timeout" do
        let(:log_output) { "Earlier line\nLogin Certificate: blahBlahBlah\nTransaction Result: java.net.SocketTimeoutException: Read timed out\nLog output" }

        it "raises a RetryableError" do
          expect {
            described_class.run_efiler_command
          }.to raise_error(Efile::GyrEfilerService::RetryableError)
        end
      end

      context "when the cause is a gyr-efiler login moved temporarily" do
        let(:log_output) do
          <<~AUDIT_LOG
            Name of Service Call: Login
            Message ID of Service Call: abcdefg
            Transaction Submission Date/Time: 2021-09-11T11:58:02Z
            ETIN of Service Call: 1234
            ASID: 121212
            Toolkit Version: 2020v11.1
            Request data: N/A
            Name of Service Call: Login
            Message ID of Service Call: abcdefg
            Transaction Result: The server sent HTTP status code 302: Moved Temporarily
          AUDIT_LOG
        end

        it "raises a RetryableError" do
          expect {
            described_class.run_efiler_command
          }.to raise_error(Efile::GyrEfilerService::RetryableError)
        end
      end

      context "when there was a SOAP connect time out" do
        let(:log_output) do
          <<~AUDIT_LOG
            Name of Service Call: Login
            Message ID of Service Call: abcdefg
            Transaction Submission Date/Time: 2021-09-20T22:33:26Z
            ETIN of Service Call: 1234
            ASID: 121212
            Login Certificate: abc123
            Toolkit Version: 2020v11.1
            Request data: N/A
            Name of Service Call: Login
            Message ID of Service Call: abcdefg
            Transaction IRS Response Date/Time:
            Transaction Result: Fault String: Error while sending a request to http://MeF-A2A-Remote/a2a/mef/Login : connect timed out - Fault Code: soap:Server - Detail: <?xml version="1.0" encoding="UTF-8"?>__
          AUDIT_LOG
        end

        it "raises a RetryableError" do
          expect {
            described_class.run_efiler_command
          }.to raise_error(Efile::GyrEfilerService::RetryableError)
        end
      end

      context "when 'unauthorized' for efile" do
        let(:log_output) { "Earlier line\nLogin Certificate: blahBlahBlah\nTransaction Result: The server sent HTTP status code 401: Unauthorized\nLog output" }

        it "raises a RetryableError" do
          expect {
            described_class.run_efiler_command
          }.to raise_error(Efile::GyrEfilerService::RetryableError)
        end
      end
    end
  end

  describe ".with_lock" do
    context "when there is no lock contention" do
      it "runs the block with lock_acquired=true" do
        described_class.with_lock(ActiveRecord::Base.connection) { |lock_acquired| expect(lock_acquired).to eq(true) }
      end
    end

    context "when there is are >5 simultaneous callers" do
      before do
        ActiveRecord::Base.clear_all_connections!
      end

      after do
        ActiveRecord::Base.clear_all_connections!
      end

      it "runs the block with lock_acquired=false" do
        described_class.with_lock(ActiveRecord::Base.connection_pool.checkout) do |lock_acquired_1|
          expect(lock_acquired_1).to eq(true)

          described_class.with_lock(ActiveRecord::Base.connection_pool.checkout) do |lock_acquired_2|
            expect(lock_acquired_2).to eq(true)

            described_class.with_lock(ActiveRecord::Base.connection_pool.checkout) do |lock_acquired_3|
              expect(lock_acquired_3).to eq(true)

              described_class.with_lock(ActiveRecord::Base.connection_pool.checkout) do |lock_acquired_4|
                expect(lock_acquired_4).to eq(true)

                described_class.with_lock(ActiveRecord::Base.connection_pool.checkout) do |lock_acquired_5|
                  expect(lock_acquired_5).to eq(true)

                  described_class.with_lock(ActiveRecord::Base.connection_pool.checkout) do |lock_acquired_6|
                    expect(lock_acquired_6).to eq(false)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
