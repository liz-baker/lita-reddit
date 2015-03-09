require 'api_calls'

module Lita
  module Handlers
    class Reddit < Handler
      class Base < Handler
        namespace 'reddit'

        def client_id
          config.client_id
        end

        def client
          @client ||= ApiCalls::new(config.client_id, config.client_secret)
        end

      end
    end
  end
end
