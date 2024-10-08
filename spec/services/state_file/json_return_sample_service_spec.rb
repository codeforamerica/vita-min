require 'rails_helper'

describe StateFile::JsonReturnSampleService do

  let(:json_return_sample_service) { StateFile::JsonReturnSampleService.new }
  let(:state_code) { 'id' }
  let(:sample_name) { 'lana_single' }
  let(:key) { 'id_lana_single' }
  let(:missing_key) { 'az_superman_does_not_exist' }
  let(:invalid_key) { 'asdf' }
  let(:label) { 'Id lana single' }
  let(:unique_file_contents) { 'Turner' }
  let(:submission_id) { '1016422024025ate000b' }
  let(:default_submission_id) { '12345202201011234570' }

  describe '.key' do
    it 'generates keys correctly' do
      expect(StateFile::JsonReturnSampleService.key(state_code, sample_name)).to eq(key)
    end
  end

  describe '#include?' do
    it 'returns true if the sample exists' do
      expect(json_return_sample_service.include?(key)).to be_truthy
    end

    it 'returns false if the sample does not exist' do
      expect(json_return_sample_service.include?(missing_key)).to be_falsey
    end

    it 'returns false if the key is invalid' do
      expect(json_return_sample_service.include?(invalid_key)).to be_falsey
    end

  end

  describe '#read' do
    it 'returns file contents if the sample exists' do
      expect(json_return_sample_service.read(key)).to include(unique_file_contents)
    end

    it 'returns nil if the sample does not exist' do
      expect(json_return_sample_service.read(missing_key)).to be_nil
    end

    it 'returns nil if the key is invalid' do
      expect(json_return_sample_service.read(invalid_key)).to be_nil
    end
  end
end
