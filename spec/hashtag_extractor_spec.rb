RSpec.describe Hshtg::HashtagExtractor, '#hashtag_extractor', focus: true do
  context 'hashtag parser' do
    it 'can parse hashtags from a single tweet' do
      text = '#one #one #two # three #One'
      tags = Hshtg::HashtagExtractor.hash_tags_from_tweet(text)
      expect(tags.count).to be(4)
    end

    it 'can group by hash tags without case sensitivity' do
      text = '#one #one #two # three #One'
      tags = Hshtg::HashtagExtractor.hash_tags_from_tweet(text)
      top  = Hshtg::HashtagExtractor.extract_tags!(tags, 5, false)
      expect(top.first.tag).to eq('one')
      expect(top.first.count).to eq(3)
      expect(top.count).to eq(2)
    end

    it 'can group by hash tags with case sensitivity' do
      text = '#one #one #two # three #One'
      tags = Hshtg::HashtagExtractor.hash_tags_from_tweet(text)
      top  = Hshtg::HashtagExtractor.extract_tags!(tags, 5, true)
      expect(top.first.tag).to eq('one')
      expect(top.first.count).to eq(2)
      expect(top.count).to eq(3)
    end

    it 'can group by hash tags and ignore garbage' do
      text = '#one #one #two # three #One #! #@HIGH !834#&#$&$# ^#_test ## #'
      tags = Hshtg::HashtagExtractor.hash_tags_from_tweet(text)
      top  = Hshtg::HashtagExtractor.extract_tags!(tags, 5, true)
      expect(top.count).to eq(3)
    end

    it 'can deal with finding no hash tags' do
      tags = Hshtg::HashtagExtractor.hash_tags_from_tweet('')
      expect(tags.count).to be(0)
    end

    it 'can deal with no HashTag items' do
      tags = Hshtg::HashtagExtractor.hash_tags_from_tweet('')
      top  = Hshtg::HashtagExtractor.extract_tags!(tags, 5, true)
      expect(top.count).to eq(0)
    end

    it 'can deal with finding nil text' do
      tags = Hshtg::HashtagExtractor.hash_tags_from_tweet(nil)
      expect(tags.count).to be(0)
    end

    it 'can deal with a nil list' do
      top = Hshtg::HashtagExtractor.extract_tags!(nil, nil, nil)
      expect(top.count).to eq(0)
    end
  end
end
