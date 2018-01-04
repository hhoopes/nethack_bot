require 'byebug'
require './lib/twitter/client'
require './map_generator'
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

  def self.on_follow

  end

  private

  def timeline
    client.mentions_timeline(timeline_options)
  end

  def timeline_options
  end
end

NethackBot.new_tweet
