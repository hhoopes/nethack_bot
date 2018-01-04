require 'byebug'
require './lib/twitter/client'
require './map_generator'
require './lib/nethack/message'
require 'figaro'
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load
class NethackBot
  extend TwitterClient

  def self.new_tweet
    map = MapGenerator.new.generate_filled_map
    self.client.update(map)
  end

  def self.respond_to_mentions
    timeline.each do |mention|
    end
  end

  def self.stream
    streaming_client.user do |object|
      case object
      when Twitter::Tweet
      when Twitter::Streaming::Event
        return unless object.name == :follow
        message = Message.follow_message(object)
      when Twitter::DirectMessage
      end
    end
  end

  private

  def follow_message(stream_object)
    screen_name = stream_object.source.screen_name
    "#{screen_name}\n" << FollowMessage.generate(screen_name)
  end

  def timeline
    client.mentions_timeline(timeline_options)
  end

  def timeline_options
  end
end

NethackBot.stream
