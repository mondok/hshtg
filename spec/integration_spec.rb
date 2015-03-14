require 'net/http'
require 'json'

RSpec.describe Hshtg, '#integrations' do
  before(:all) do
    Hshtg::Utils.load_env_vars

    puts 'Starting server for tests'
    Thread.new { Hshtg::ServerBootstrapper.start }
    sleep 10
  end
  after(:all) do
    puts 'Stopping server for tests'
    Hshtg::ServerBootstrapper.stop
  end

  context 'server' do
    SERVER_HOST = 'http://localhost:3000'
    it 'can be queried with top10' do
      response = Net::HTTP.get_response(URI("#{SERVER_HOST}/top10"))
      results = JSON.parse(response.body)
      expect(results.count).to be_between(1, 10)
    end

    it 'can take a malformed top* request' do
      response = Net::HTTP.get_response(URI("#{SERVER_HOST}/top105thousandy"))
      expect(response.code).to eq('500')
    end

    it 'will respond with 500 if top0 is passed' do
      response = Net::HTTP.get_response(URI("#{SERVER_HOST}/top0"))
      expect(response.code).to eq('500')
    end

    it 'will respond with 404 if invalid endpoint is passed' do
      response = Net::HTTP.get_response(URI("#{SERVER_HOST}/helloWorld"))
      expect(response.code).to eq('404')
    end

    it 'will respond with HTTP GET health check' do
      response = Net::HTTP.get_response(URI("#{SERVER_HOST}/health"))
      expect(response.code).to eq('200')
      expect(response.body).to include('status: up')
    end

    it 'will respond with HTTP GET live page' do
      response = Net::HTTP.get_response(URI("#{SERVER_HOST}/live"))
      expect(response.code).to eq('200')
      expect(response.body).to include('Hashtag Test Page')
    end

    it 'will respond with HTTP HEAD health check' do
      uri = URI(SERVER_HOST)
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.head('/')
      expect(response['Status']).to eq('up')
    end
  end
end
