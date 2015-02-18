require 'redd'

module Lita
  module Handlers
    class Reddit < Handler
        config :reddits, types: Array, required: true
        config :client_id, type: String, required: true
        config :client_secret, type: String, required: true
        config :mod do
            config :reddits, type: Array
        end
        config :poll_interval, type: Integer, default: 300

        on :connected, :setup

        def setup(payload)
            after(30) do
                check_posts
                every(config.poll_interval) do |timer|
                    check_posts
                end
            end
        end

        def check_posts
            userless = Redd.it(:userless, config.client_id, config.client_secret)
            post_text = 'From /r/%s: %s (%s)'
            redis_key = 'last_seen_%s_%s'
            config.reddits.each do |reddit|
                last_seen = redis.get(redis_key % [reddit[:channel], reddit[:subreddit]]) or nil
                target = Source.new(room: reddit[:channel])
                posts =  userless.get_new(reddit[:subreddit], before: last_seen, limit:3)
                posts.each do |post|
                    robot.send_message(target, post_text % [post.subreddit, post.title, post.url])
                end
                redis.set(redis_key % [reddit[:channel], reddit[:subreddit]], posts[0].fullname)
            end
        end 
    end

    Lita.register_handler(Reddit)
  end
end
