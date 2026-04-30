require 'rails_helper'

describe RefreshCachesJob, type: :job do
  describe '#perform' do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }    
    let(:cache) { Rails.cache }
    let(:cache_key) { AiScreenerMetricsService::CACHE_KEY }
    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end
    it 'refreshes cache for registered classes' do
      expect(cache.exist?(cache_key)).to be(false)
      RefreshCachesJob.new.perform
      expect(cache.exist?(cache_key)).to be(true)
    end
  end
end
