require 'zip'
module Efile
  class GyrEfilerService
    CURRENT_VERSION = 'f5eeb816f6c919fff8d5c742062e664b1f4cd13a'
    POSTGRES_LOCK_PREFIX = 1640661264

    def self.run_efiler_command(*args)
      Dir.mktmpdir do |working_directory|
        FileUtils.mkdir_p(File.join(working_directory, "output", "log"))
        ensure_config_dir_prepared

        # TODO: If the process blocks for >10 min, terminate it.
        # TODO: Send process stdout to logs.
        # TODO: Send output/logs/ to logs after process terminates.
        classes_zip_path = ensure_gyr_efiler_downloaded

        config_dir = Rails.root.join("tmp", "gyr_efiler", "gyr_efiler_config").to_s

        # On macOS, "java" will show a confusing pop-up if you run it without a JVM installed. Check for that and exit early.
        if File.exists?("/Library/Java/JavaVirtualMachines") && Dir.glob("/Library/Java/JavaVirtualMachines/*").empty?
          raise Error.new("Seems you are on a mac & lack Java. Run: brew tap AdoptOpenJDK/openjdk && brew install adoptopenjdk8")
        end
        # /Library/Java/JavaVirtualMachines
        java = ENV["VITA_MIN_JAVA_HOME"] ? File.join(ENV["VITA_MIN_JAVA_HOME"], "bin", "java") : "java"

        argv = [java, "-cp", classes_zip_path, "org.codeforamerica.gyr.efiler.App", config_dir, *args]
        Rails.logger.info "Running: #{argv.inspect}"
        pid = Process.spawn(*argv,
          unsetenv_others: true,
          chdir: working_directory,
          in: "/dev/null"
        )
        Process.wait(pid)
        raise Error.new("Process failed to exit?") unless $?.exited?

        exit_code = $?.exitstatus
        if exit_code != 0
          log_contents = File.read(File.join(working_directory, 'output/log/audit_log.txt'))
          if log_contents.split("\n").include?("Transaction Result: java.net.SocketTimeoutException: Read timed out")
            raise RetryableError, log_contents
          elsif log_contents.match(/Transaction Result: The server sent HTTP status code 302: Moved Temporarily/)
            raise RetryableError, log_contents
          elsif log_contents.match(/connect timed out - Fault Code: soap:Server/)
            raise RetryableError, log_contents
          else
            raise Error, log_contents
          end
        end

        get_single_file_from_zip(Dir.glob(File.join(working_directory, "output", "*.zip"))[0])
      end
    end

    def self.get_single_file_from_zip(zipfile_path)
      Zip::File.open(zipfile_path) do |zipfile|
        entries = zipfile.entries
        raise StandardError.new("Zip file contains more than 1 file") if entries.size != 1
        # In that case, might be good to archive the ZIP file before the working directory gets deleted

        return zipfile.read(entries.first.name)
      end
    end

    def self.ensure_config_dir_prepared
      config_dir = Rails.root.join("tmp", "gyr_efiler", "gyr_efiler_config")
      FileUtils.mkdir_p(config_dir)
      return if File.exists?(File.join(config_dir, '.ready'))

      config_zip_path = Dir.glob(Rails.root.join("vendor", "gyr_efiler", "gyr-efiler-config-#{CURRENT_VERSION}.zip"))[0]
      raise StandardError.new("Please run rake setup:download_gyr_efiler then try again") if config_zip_path.nil?

      system!("unzip -o #{config_zip_path} -d #{Rails.root.join("tmp", "gyr_efiler")}")

      local_efiler_repo_config_path = File.expand_path('../gyr-efiler/gyr_efiler_config', Rails.root)
      if Rails.env.development?
        begin
          FileUtils.cp(File.join(local_efiler_repo_config_path, 'gyr_secrets.properties'), config_dir)
          FileUtils.cp(File.join(local_efiler_repo_config_path, 'secret_key_and_cert.p12.key'), config_dir)
        rescue
          raise StandardError.new("Please clone the gyr-efiler repo to ../gyr-efiler and follow its README")
        end
      else
        app_sys_id, efile_cert_base64, etin = config_values

        properties_content = <<~PROPERTIES
          etin=#{etin}
          app_sys_id=#{app_sys_id}
        PROPERTIES
        File.write(File.join(config_dir, 'gyr_secrets.properties'), properties_content)
        File.write(File.join(config_dir, 'secret_key_and_cert.p12.key'), Base64.decode64(efile_cert_base64), mode: "wb")
      end

      FileUtils.touch(File.join(config_dir, '.ready'))
    end

    def self.ensure_gyr_efiler_downloaded
      classes_zip_path = Dir.glob(Rails.root.join("vendor", "gyr_efiler", "gyr-efiler-classes-#{CURRENT_VERSION}.zip"))[0]
      raise StandardError.new("You must run rails setup:download_gyr_efiler") if classes_zip_path.nil?

      return classes_zip_path
    end

    def self.with_lock(connection)
      # Usage:
      #   with_lock(ActiveRecord::Base.connection) { |lock_acquired| if lock_acquired; do_work; else; handle_lock_acquisition_failure; end )}
      #
      # Allows 5 simultaneous lock holders because the IRS says they permit 5 simultaneous login sessions.
      lock_namespace = connection.quote(POSTGRES_LOCK_PREFIX)
      connection.transaction do
        result = connection.execute("SELECT pg_try_advisory_xact_lock(#{lock_namespace}, 1) OR pg_try_advisory_xact_lock(#{lock_namespace}, 2) OR pg_try_advisory_xact_lock(#{lock_namespace}, 3) OR pg_try_advisory_xact_lock(#{lock_namespace}, 4) OR pg_try_advisory_xact_lock(#{lock_namespace}, 5) as lock_acquired")
        yield result[0]["lock_acquired"]
      end
    end

    class RetryableError < StandardError; end

    class Error < StandardError; end

    private

    def self.system!(*args)
      system(*args) || abort("\n== Command #{args} failed ==")
    end

    def self.config_values
      # On our Aptible environments, these config values should be in Rails secrets aka EnvironmentCredentials.
      #
      # They can also be configured by environment variables, which is convenient for local dev or manual testing.
      app_sys_id = ENV['GYR_EFILER_APP_SYS_ID'].presence || EnvironmentCredentials.dig(:irs, :app_sys_id)
      efile_cert_base64 = ENV['GYR_EFILER_CERT'].presence || EnvironmentCredentials.dig(:irs, :efile_cert_base64)
      etin = ENV['GYR_EFILER_ETIN'].presence || EnvironmentCredentials.dig(:irs, :etin)
      if app_sys_id.nil? || efile_cert_base64.nil? || etin.nil?
        raise Error.new("Missing app_sys_id and/or efile_cert_base64 and/or etin configuration")
      end

      [app_sys_id, efile_cert_base64, etin]
    end
  end
end
