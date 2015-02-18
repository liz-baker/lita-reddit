require 'thread'
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
      config :startup_delay, type: Integer, default: 30

      on :connected, :setup


      def setup(payload)
        after(config.startup_delay) do
          setup_streams
        end
      end

      def setup_streams
        post_text = 'From /r/%s: %s (%s)'
        base_redis_key = 'seen_list_%s_%s'
        config.reddits.each do |reddit|
          Thread.new {
            #new on the left
            redis_key = base_redis_key % [reddit[:channel], reddit[:subreddit]]
            post_limit = 3
            seen_reddits = redis.lrange(redis_key, 0, post_limit - 1)
            userless = Redd.it(:userless, config.client_id, config.client_secret, user_agent: 'lita-reddit/1.0')
            Lita.logger.debug('setting up stream for %s' % [reddit[:subreddit]])
            target = Source.new(room: reddit[:channel])
            userless.stream :get_new, reddit[:subreddit], limit: post_limit do |post|
              if !seen_reddits.include?(post.fullname) then
                robot.send_message(target, post_text % [post.subreddit, post.title, post.short_url])
                redis.lpush(redis_key, post.fullname)
              end
              redis.ltrim(redis_key, 0, post_limit - 1)
            end
          }
          Lita.logger.debug('finished setting up stream for %s' % [reddit[:subreddit]])
        end
      end 
    end

    Lita.register_handler(Reddit)
  end
end
