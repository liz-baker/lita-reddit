require 'api_calls'

module Lita
  module Handlers
    class Reddit < Handler
      class Base < Reddit
        namespace 'reddit'

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

        def client
          @client ||= ApiCalls::new(config.client_id, config.client_secret)
        end

      end
    end
  end
end
