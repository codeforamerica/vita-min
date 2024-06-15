module StateFile
  class XmlReturnSampleService
    def initialize
      @_samples = {}
      @_submission_id_lookup = {
        'ny_rudy_v2' => '1016422024027ate001k',
        'ny_javier' => '1016422024018atw000x',
        'ny_matthew_v2' => '1016422024026atw001u',
        'ny_khaled' => '1016422024009at0000z',
        'ny_ivy_414h' => '1016422024025atw000h',
        'az_leslie_qss_v2' => '1016422024026atw001h',
        'az_donald_v2' => '1016422024027atw0020',
        'az_robin_v2' => '1016422024028ate001q',
        'az_superman_v2' => '1016422024025ate000b'
      }
      @old_sample = "app/controllers/state_file/questions/df_return_sample.xml"
    end

    def samples
      load_samples
      @_samples
    end

    def self.key(us_state, sample_name)
      "#{us_state}_#{sample_name}"
    end

    def self.label(sample_name)
      sample_name.humanize
    end

    def lookup_submission_id(key)
      @_submission_id_lookup[key] || '12345202201011234570'
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

    private

    BASE_PATH = "spec/fixtures/state_file/fed_return_xmls/".freeze
    TAX_YEAR = Rails.configuration.statefile_current_tax_year.to_s.freeze

    def load_samples
      return if @_samples.present?

      StateFile::StateInformationService.active_state_codes.each do |us_state|
        @_samples[us_state] = []
        xml_path_glob = File.join(BASE_PATH, TAX_YEAR, us_state, '*.xml')
        Dir.glob(xml_path_glob).each do |xml_path|
          @_samples[us_state].push(File.basename(xml_path, ".xml"))
        end
      end
    end

    def path(key)
      load_samples
      return @old_sample if key == "abcdefg"

      us_state, sample_name = key.split("_", 2)
      if @_samples[us_state].include? sample_name
        File.join(BASE_PATH, TAX_YEAR, us_state, "#{sample_name}.xml")
      end
    end
  end
end

