require_relative "api_calls"
module Lita
  module Handlers
    class Reddit < Handler
      class Base < Handler
        namespace "reddit"

        def reddits
          config.reddits
        end

        def startup_delay
          config.startup_delay
        end

        def poll_interval
          config.poll_interval
        end

        def post_limit
          config.post_limit
        end

        def post_text
          config.post_text
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
