require 'rails_helper'

describe StateFile::DirectFileApiResponseSampleService do
  let(:direct_file_api_response_return_sample_service) { StateFile::DirectFileApiResponseSampleService.new }
  let(:state_code) { 'id' }
  let(:sample_name) { 'lana_single' }
  let(:key) { 'id_lana_single' }
  let(:missing_key) { 'az_superman_does_not_exist' }
  let(:invalid_key) { 'asdf' }
  let(:label) { 'Id lana single' }
  let(:unique_file_contents) { 'Turner' }
  let(:old_sample_unique_file_contents) { 'TESTERSON' }
  let(:submission_id) { '1016422024025ate000b' }
  let(:default_submission_id) { '12345202201011234570' }

  describe '.key' do
    it 'generates keys correctly' do
      expect(StateFile::DirectFileApiResponseSampleService.key(state_code, sample_name)).to eq(key)
    end
  end

  describe '.label' do
    it 'generates labels correctly' do
      expect(StateFile::DirectFileApiResponseSampleService.label(key)).to eq label
    end
  end

  describe '#lookup_submission_id' do
    let(:key) { 'az_superman_v2' }

    it 'returns stored submission ids for samples that have one' do
      expect(direct_file_api_response_return_sample_service.lookup_submission_id(key)).to eq submission_id
    end

    it 'returns the default submission id if one is not found' do
      expect(direct_file_api_response_return_sample_service.lookup_submission_id(missing_key)).to eq default_submission_id
    end
  end

  describe '#include?' do
    it 'returns true if the sample exists' do
      expect(direct_file_api_response_return_sample_service.include?(key, 'xml')).to be_truthy
    end

    it 'returns false if the sample does not exist' do
      expect(direct_file_api_response_return_sample_service.include?(missing_key, 'xml')).to be_falsey
    end

    it 'returns false if the key is invalid' do
      expect(direct_file_api_response_return_sample_service.include?(invalid_key, 'xml')).to be_falsey
    end

  end

  describe '#read_xml' do
    it 'returns file contents if the sample exists' do
      expect(direct_file_api_response_return_sample_service.read_xml(key)).to include(unique_file_contents)
    end

    it 'returns nil if the sample does not exist' do
      expect(direct_file_api_response_return_sample_service.read_xml(missing_key)).to be_nil
    end

    it 'returns nil if the key is invalid' do
      expect(direct_file_api_response_return_sample_service.read_xml(invalid_key)).to be_nil
    end
  end

  describe '#read_json' do
    it 'returns file contents if the sample exists' do
      expect(direct_file_api_response_return_sample_service.read_json(key)).to include(unique_file_contents)
    end

    it 'returns nil if the sample does not exist' do
      expect(direct_file_api_response_return_sample_service.read_json(missing_key)).to be_nil
    end

    it 'returns nil if the key is invalid' do
      expect(direct_file_api_response_return_sample_service.read_json(invalid_key)).to be_nil
    end
  end

  describe '#old_xml_sample' do
    it 'returns the old sample file contents' do
      expect(direct_file_api_response_return_sample_service.old_xml_sample).to include(old_sample_unique_file_contents)
    end
  end
end