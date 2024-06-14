module StateFile
  class XmlReturnSampleService
    def initialize
      @_samples = {}
      @_submission_id_lookup = {
        '2023_ny_rudy_v2.xml' => '1016422024027ate001k',
        '2023_ny_javier.xml' => '1016422024018atw000x',
        '2023_ny_matthew_v2.xml' => '1016422024026atw001u',
        '2023_ny_khaled.xml' => '1016422024009at0000z',
        '2023_ny_ivy_414h.xml' => '1016422024025atw000h',
        '2023_az_leslie_qss_v2.xml' => '1016422024026atw001h',
        '2023_az_donald_v2.xml' => '1016422024027atw0020',
        '2023_az_robin_v2.xml' => '1016422024028ate001q',
        '2023_az_superman_v2.xml' => '1016422024025ate000b'
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
      File.read(path(key))
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

