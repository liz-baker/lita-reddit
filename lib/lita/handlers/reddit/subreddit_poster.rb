module Lita
  module Handlers
    class Reddit < Handler
      class SubredditPoster < Base
        namespace 'reddit'
        on :connected, :setup
        on :reddit_update_token, :update_token
        on :reddit_refresh_posts, :refresh_posts

        def setup(payload)
          after(startup_delay) do
            robot.trigger(:reddit_update_token)
          end
          every (poll_interval) do
            robot.trigger(:reddit_refresh_posts)
          end
          # update userless token once per hour
          every (3300) do
            robot.trigger(:reddit_update_token)
          end
        end

        def update_token(payload)
          client.update_token(http())
          robot.trigger(:reddit_refresh_posts)
        end

        def refresh_posts(payload)
          post_text = 'From /r/%s: %s (http://redd.it/%s)'
          base_redis_key = 'seen_list_%s_%s'
          reddits.each do |reddit|
            log.debug('lita-reddit: updating posts for /r/%s' % [reddit[:subreddit]])
            #new on the left
            redis_key = base_redis_key % [reddit[:channel], reddit[:subreddit]]
            seen_reddits = redis.lrange(redis_key, 0, 10)
            target = Source.new(room: reddit[:channel])
            results = client.get_posts(http(), reddit[:subreddit], redis.lindex(redis_key, 0))
            results.reverse.each do |post|
              if !seen_reddits.include?(post[:id]) then
                robot.send_message(target, post_text % [post[:subreddit], post[:title], post[:id]])
                redis.lpush(redis_key, post[:id])
              end

              # keep a few extra around, 10 is still instantaneous
              redis.ltrim(redis_key, 0, 10)
            end
          end
        end 
      end
      Lita.register_handler(SubredditPoster)
    end
  end
end
