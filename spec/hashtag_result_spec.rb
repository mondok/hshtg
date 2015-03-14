RSpec.describe Hshtg::Models, '#hashtag_models', focus: true do
  context 'Hashtag' do
    it 'can be initialized with a tag' do
      htag = Hshtg::Models::Hashtag.new('Dummy')
      expect(htag.tag).to eq('Dummy')
    end

    it 'can be fresh' do
      htag = Hshtg::Models::Hashtag.new('Dummy')
      expect(htag.fresh?).to be_truthy
    end

    it 'can be stale' do
      htag = Hshtg::Models::Hashtag.new('Dummy')
      htag.timestamp = Time.now - 61
      expect(htag.fresh?).to be_falsey
    end

    it 'can be fresh with custom expiration' do
      htag = Hshtg::Models::Hashtag.new('Dummy')
      htag.timestamp = Time.now - 195
      expect(htag.fresh?(200)).to be_truthy
    end

    it 'can be stale with custom expiration' do
      htag = Hshtg::Models::Hashtag.new('Dummy')
      htag.timestamp = Time.now - 200
      expect(htag.fresh?(195)).to be_falsey
    end
  end

  context 'HashtagResult' do

  end
end
