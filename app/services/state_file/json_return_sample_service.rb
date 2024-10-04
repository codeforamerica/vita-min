module StateFile
  class JsonReturnSampleService
    def initialize
      @samples = {}
      @old_sample = "app/controllers/state_file/questions/df_return_sample.json"
    end

    def samples
      load_samples
      @samples
    end

    def self.key(us_state, sample_name)
      "#{us_state}_#{sample_name}"
    end

    def self.label(sample_name)
      sample_name.humanize
    end

    def include?(key)
      path(key).present?
    end

    def read(key)
      File.read(path(key)) if include?(key)
    end

    def old_sample
      read("abcdefg")
    end

    def az_json_sample(filing_status)
      case filing_status.to_sym
      when :single
        read("az_tycho_loanded")
      when :married_filing_jointly
        read("az_martha_v2")
      when :qualifying_widow
        read("az_leslie_qss_v2")
      when :married_filing_separately
        read("az_sherlock_mfs")
      when :head_of_household
        read("az_alexis_hoh_w2_and_1099")
      end
    end

    private

    BASE_PATH = "spec/fixtures/state_file/fed_return_jsons/".freeze
    TAX_YEAR = Rails.configuration.statefile_current_tax_year.to_s.freeze

    def load_samples
      return if @samples.present?

      StateFile::StateInformationService.active_state_codes.each do |us_state|
        @samples[us_state] = []
        json_path_glob = File.join(BASE_PATH, TAX_YEAR, us_state, '*.json')
        Dir.glob(json_path_glob).each do |json_path|
          @samples[us_state].push(File.basename(json_path, ".json"))
        end
      end
    end

    def path(key)
      load_samples
      return @old_sample if key == "abcdefg"

      us_state, sample_name = key.split("_", 2)
      if @samples.include?(us_state) && @samples[us_state].include?(sample_name)
        File.join(BASE_PATH, TAX_YEAR, us_state, "#{sample_name}.json")
      end
    end
  end
end

