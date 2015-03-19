require_relative "api_calls"
module Lita
  module Handlers
    class Reddit < Handler
      class Base < Handler
        namespace "reddit"

        def startup_delay
          config.startup_delay
        end

        def reddits
          config.subreddit_poster.reddits
        end

        def poll_interval
          config.subreddit_poster.poll_interval
        end

        def post_limit
          config.subreddit_poster.post_limit
        end

        def post_text
          config.subreddit_poster.post_text
        end

        def client
          if @client.nil?
            @client = Lita::Handlers::Reddit::ApiCalls.new(config.client_id, config.client_secret)
          end
          @client
        end
      end
    end
  end
end
