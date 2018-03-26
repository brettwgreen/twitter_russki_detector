#!/usr/bin/env ruby
require 'twitter'
require 'optparse'
require 'awesome_print'

options = {}
OptionParser.new do |opts|
  opts.on("-u", "--user USER", "User to a analyze") do |v|
    options[:user] = v
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def get_all_tweets(client, user)
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: true}
    options[:max_id] = max_id unless max_id.nil?
    client.user_timeline(user, options)
  end
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
  config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
  config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
end

user = client.user(options[:user])
# ap user
tweets = get_all_tweets(client, options[:user])
locations = tweets.map{|t|
  place = t.to_h[:place]
  [place[:full_name], place[:country_code]] if place
}.uniq
ap locations
