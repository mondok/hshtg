RSpec.describe Hshtg::Storage, '#memory_store', focus: true do
  context 'InMemoryStore' do
    it 'can be initialized' do
      store = Hshtg::Storage::InMemoryStore.new
      expect(store).to_not be_nil
    end

    it 'can add Hashtags' do
      store = Hshtg::Storage::InMemoryStore.new
      store.add_tags(hashtag_list)
      expect(hashtag_list.count).to be > 0
      expect(store.all.count).to eq(hashtag_list.count)
    end

    it 'can get fresh hashtags' do
      store             = Hshtg::Storage::InMemoryStore.new
      list              = hashtag_list
      list[0].timestamp = Time.now - 100
      store.add_tags(list)
      expect(store.fresh_tags.count).to eq(list.count-1)
    end

    it 'can evict stale hashtags' do
      store             = Hshtg::Storage::InMemoryStore.new
      list              = hashtag_list
      list[0].timestamp = Time.now - 100
      store.add_tags(list)
      store.evict_old_tags
      expect(store.fresh_tags.count).to eq(list.count-1)
    end

    it 'can get fresh hashtags with custom time' do
      store             = Hshtg::Storage::InMemoryStore.new
      list              = hashtag_list
      list[0].timestamp = Time.now - 100
      store.add_tags(list)
      expect(store.fresh_tags(120).count).to eq(list.count)
    end

    it 'can evict stale hashtags with custom time' do
      store             = Hshtg::Storage::InMemoryStore.new
      list              = hashtag_list
      list[0].timestamp = Time.now - 100
      store.add_tags(list)
      store.evict_old_tags(10)
      expect(store.fresh_tags.count).to eq(list.count-1)
    end

  end


end
