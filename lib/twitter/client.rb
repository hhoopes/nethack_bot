require 'twitter'
require 'figaro'
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

module TwitterClient
  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = Figaro.env.twitter_consumer_key
      config.consumer_secret     = Figaro.env.twitter_consumer_secret
      config.access_token        = Figaro.env.twitter_access_token
      config.access_token_secret = Figaro.env.twitter_access_secret
    end
  end

  def streaming_client
    @streaming_client ||= Twitter::Streaming::Client.new do |config|
      config.consumer_key        = Figaro.env.twitter_consumer_key
      config.consumer_secret     = Figaro.env.twitter_consumer_secret
      config.access_token        = Figaro.env.twitter_access_token
      config.access_token_secret = Figaro.env.twitter_access_secret
    end
  end

end
