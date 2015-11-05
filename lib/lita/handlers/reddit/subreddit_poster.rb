module Lita
  module Handlers
    class Reddit < Handler
      class SubredditPoster < Base
        namespace "reddit"
        on :connected, :setup
        on :reddit_update_token, :update_token
        on :reddit_refresh_posts, :refresh_posts

        def setup(_payload)
          after startup_delay do
            robot.trigger(:reddit_update_token)
          end
          every poll_interval do
            robot.trigger(:reddit_refresh_posts)
          end
          # update userless token once per hour
          every 3300 do
            robot.trigger(:reddit_update_token)
          end
        end

        def update_token(_payload)
          client.update_token
          robot.trigger(:reddit_refresh_posts)
        rescue Exception => msg
          log.error("lita-reddit: Exception during token update: #{msg}")
        end

        def refresh_posts(_payload)
          base_redis_key = "seen_list_%s_%s"
          reddits.each do |reddit|
            log.debug("lita-reddit: updating posts for /r/#{reddit[:subreddit]}")
            # new on the left
            redis_key = format(base_redis_key, reddit[:channel], reddit[:subreddit])
            seen_reddits = redis.lrange(redis_key, 0, 10)
            target = Source.new(room: reddit[:channel])
            results = client.get_posts(reddit[:subreddit],
                                       redis.lindex(redis_key, 0),
                                       post_limit)
            results.reverse.each do |post|
              unless seen_reddits.include?(post[:id])
                robot.send_message(target, CGI::unescapeHTML(post_text % post))
                redis.lpush(redis_key, post[:id])
              end

              # keep a few extra around, 10 is still instantaneous
              redis.ltrim(redis_key, 0, 10)
            end
          end
          rescue Exception => msg
            log.error("lita-reddit: Exception during post update #{msg}")
        end
      end
      Lita.register_handler(SubredditPoster)
    end
  end
end
