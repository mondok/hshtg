require 'optparse'

RSpec.describe Hshtg::Util::OptsParser, '#opts_parser', focus: true do
  context 'Options' do
    it 'can enable case sensitivity' do
      options = Hshtg::Util::OptsParser.options(['-c', '1'])
      expect(options[:case]).to be_truthy
    end
    it 'can disable case sensitivity' do
      options = Hshtg::Util::OptsParser.options(['--case', '0'])
      expect(options[:case]).to be_falsey
    end

    it 'can enable automatic restart' do
      options = Hshtg::Util::OptsParser.options(['-r', '1'])
      expect(options[:automatic_restart]).to be_truthy
    end
    it 'can disable automatic restart' do
      options = Hshtg::Util::OptsParser.options(['--restart', '0'])
      expect(options[:automatic_restart]).to be_falsey
    end

    it 'can change the default ttl' do
      options = Hshtg::Util::OptsParser.options(['-t', '1'])
      expect(options[:ttl]).to eq(1)
    end
    it 'can change the default ttl longform' do
      options = Hshtg::Util::OptsParser.options(['--ttl', '1'])
      expect(options[:ttl]).to eq(1)
    end

    it 'can change the default logging' do
      options = Hshtg::Util::OptsParser.options(['-l', 'file.log'])
      expect(options[:log_device]).to eq('file.log')
    end
    it 'can change the default log_device longform' do
      options = Hshtg::Util::OptsParser.options(['--logging', 'file.log'])
      expect(options[:log_device]).to eq('file.log')
    end

    it 'can change the default port' do
      options = Hshtg::Util::OptsParser.options(['-p', '1'])
      expect(options[:port]).to eq(1)
    end
    it 'can change the default port longform' do
      options = Hshtg::Util::OptsParser.options(['--port', '1'])
      expect(options[:port]).to eq(1)
    end

    it 'can change the storage to in-memory' do
      options = Hshtg::Util::OptsParser.options(['--store', 'in-memory'])
      expect(options[:storage]).to eq(Hshtg::Storage::InMemoryStore)
    end

    it 'can read settings from a yaml file' do
      options = Hshtg::Util::OptsParser.options(['--file', './spec/dummy_settings.yml'])
      expect(options[:storage]).to eq(Hshtg::Storage::InMemoryStore)
      expect(options[:case]).to eq(true)
      expect(options[:port]).to eq(999)
      expect(options[:ttl]).to eq(1)
      expect(options[:log_device]).to eq('file.log')
    end

    it 'can ignore a bad yaml file' do
      options = Hshtg::Util::OptsParser.options(['--file', './spec/i_dont_exist.yml'])
      expect(options[:storage]).to eq(Hshtg::Storage::InMemoryStore)
      expect(options[:case]).to eq(false)
      expect(options[:port]).to eq(3000)
      expect(options[:ttl]).to eq(60)
      expect(options[:log_device]).to eq(STDOUT)
    end

  end

end
