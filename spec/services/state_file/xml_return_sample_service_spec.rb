require 'rails_helper'

describe StateFile::XmlReturnSampleService do

  let(:xml_return_sample_service) { StateFile::XmlReturnSampleService.new }
  let(:state_code) { 'az' }
  let(:sample_name) { 'superman_v2' }
  let(:key) { 'az_superman_v2' }
  let(:missing_key) { 'az_superman_does_not_exist' }
  let(:invalid_key) { 'asdf' }
  let(:label) { 'Az superman v2' }
  let(:unique_file_contents) { 'KENT' }
  let(:old_sample_unique_file_contents) { 'TESTERSON' }
  let(:submission_id) { '1016422024025ate000b' }
  let(:default_submission_id) { '12345202201011234570' }

  describe '.key' do
    it 'generates keys correctly' do
      expect(StateFile::XmlReturnSampleService.key(state_code, sample_name)).to eq(key)
    end
  end

  describe '.label' do
    it 'generates labels correctly' do
      expect(StateFile::XmlReturnSampleService.label(key)).to eq label
    end
  end

  describe '#lookup_submission_id' do
    it 'returns stored submission ids for samples that have one' do
      expect(xml_return_sample_service.lookup_submission_id(key)).to eq submission_id
    end

    it 'returns the default submission id if one is not found' do
      expect(xml_return_sample_service.lookup_submission_id(missing_key)).to eq default_submission_id
    end
  end

  describe '#include?' do
    it 'returns true if the sample exists' do
      expect(xml_return_sample_service.include?(key)).to be_truthy
    end

    it 'returns false if the sample does not exist' do
      expect(xml_return_sample_service.include?(missing_key)).to be_falsey
    end

    it 'returns false if the key is invalid' do
      expect(xml_return_sample_service.include?(invalid_key)).to be_falsey
    end

  end

  describe '#read' do
    it 'returns file contents if the sample exists' do
      expect(xml_return_sample_service.read(key)).to include(unique_file_contents)
    end

    it 'returns nil if the sample does not exist' do
      expect(xml_return_sample_service.read(missing_key)).to be_nil
    end

    it 'returns nil if the key is invalid' do
      expect(xml_return_sample_service.read(invalid_key)).to be_nil
    end
  end

  describe '#old_sample' do
    it 'returns the old sample file contents' do
      expect(xml_return_sample_service.old_sample).to include(old_sample_unique_file_contents)
    end
  end

end
