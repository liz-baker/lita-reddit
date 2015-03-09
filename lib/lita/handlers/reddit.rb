module Lita
  module Handlers
    class Reddit < Handler
      # base config required for API access
      config :client_id, type: String, required: true
      config :client_secret, type: String, required: true
      
      # SubredditPoster config
      config :subreddit_poster do
        config :reddits, types: Array 
        config :startup_delay, type: Integer, default: 30
        config :poll_interval, type: Integer, default: 300
        config :post_limit, type: Integer, default: 3
      end

      config :mod do
        config :base_url, type: String
        config :reddits, type: Array
      end

    end
    Lita.register_handler(Reddit)
  end
end
