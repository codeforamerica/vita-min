module StateFile
  class XmlReturnSampleService
    def initialize(tax_year: nil)
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
    end

    def samples
      load_samples
      @_samples
    end

    def self.key(tax_year, us_state, filename)
      "#{tax_year}_#{us_state}_#{filename}"
    end

    def self.label(filename)
      filename.gsub(".xml", "").humanize
    end

    def lookup_submission_id(key)
      @_submission_id_lookup[key] || '12345202201011234570'
    end

    def read(key)
      File.read(path(key))
    end

    def old_sample
      read("abcdefg")
    end

    private

    BASE_PATH = "spec/fixtures/state_file/fed_return_xmls/"

    def load_samples
      return if @_samples.present?

      UsStateConfigService.active_states_by_year.each do |tax_year, active_us_states|
        @_samples[tax_year] = {}
        active_us_states.each do |us_state|
          @_samples[tax_year][us_state] = []
          xml_path_glob = File.join(BASE_PATH, tax_year.to_s, us_state.to_s, '*.xml')
          Dir.glob(xml_path_glob).each do |xml_path|
            @_samples[tax_year][us_state].push(File.basename(xml_path))
          end
        end
      end

      # TODO: decide where to put this, since it doesn't follow our path structure yet
      #   Probably just move it into 2023/ny
      # @_samples[2023][:ny]['df_return_sample.xml'] = "app/controllers/state_file/questions/df_return_sample.xml"
    end

    def path(key)
      tax_year, us_state, filename = key.split("_", 3)
      File.join(BASE_PATH, tax_year.to_s, us_state.to_s, filename)
    end
  end
end

