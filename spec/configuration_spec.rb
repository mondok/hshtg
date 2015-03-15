RSpec.describe Hshtg::Util::Configuration, '#configuration', focus: true do
  hash_config = Hshtg::Util::Configuration

  context 'general configuration management' do
    it 'can properly create a uri' do
      expect(hash_config.streaming_endpoint).to_not be_nil
    end

    it 'can check validity' do
      ENV[hash_config::ACCESS_TOKEN_KEY_NAME]    = '123'
      ENV[hash_config::ACCESS_TOKEN_SECRET_NAME] = '456'
      ENV[hash_config::CONSUMER_KEY_NAME]        = '789'
      ENV[hash_config::CONSUMER_SECRET_NAME]     = '0'
      expect(hash_config.is_valid?).to be_truthy
    end

    it 'can be invalid' do
      ENV[hash_config::ACCESS_TOKEN_KEY_NAME]    = '123'
      ENV[hash_config::ACCESS_TOKEN_SECRET_NAME] = '456'
      ENV[hash_config::CONSUMER_KEY_NAME]        = '789'
      ENV[hash_config::CONSUMER_SECRET_NAME]     = nil
      expect(hash_config.is_valid?).to be_falsey
    end

    it 'can be false case sensitive on matching' do
      value                               = false
      hash_config.case_sensitive_matching = value
      expect(hash_config.case_sensitive_matching).to eq(value)
    end

    it 'can be true case sensitive on matching' do
      value                               = true
      hash_config.case_sensitive_matching = value
      expect(hash_config.case_sensitive_matching).to eq(value)
    end

    it 'can default time to 60 seconds' do
      expect(hash_config.tag_time_to_live_in_seconds).to eq(60)
    end
  end

  context 'environment variables' do
    it 'can properly set access token' do
      value                                           = 'abc'
      ENV[hash_config::ACCESS_TOKEN_KEY_NAME] = value
      token                                           = hash_config.access_token
      expect(token).to eq(value)
    end

    it 'can properly set access token secret' do
      value                                              = 'def'
      ENV[hash_config::ACCESS_TOKEN_SECRET_NAME] = value
      token                                              = hash_config.access_token_secret
      expect(token).to eq(value)
    end

    it 'can properly set consumer key' do
      value                                       = 'ghi'
      ENV[hash_config::CONSUMER_KEY_NAME] = value
      token                                       = hash_config.consumer_key
      expect(token).to eq(value)
    end

    it 'can properly set consumer secret' do
      value                                          = 'jkl'
      ENV[hash_config::CONSUMER_SECRET_NAME] = value
      token                                          = hash_config.consumer_secret
      expect(token).to eq(value)
    end
  end
end
