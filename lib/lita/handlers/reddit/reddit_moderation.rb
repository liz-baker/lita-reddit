module Lita
  module Handlers
    class Reddit < Handler
      class RedditModeration < Base
        namespace 'reddit'
        def base_url
          config.mod.base_url
        end
        route(/reddit auth/, :authenticate, restrict_to: :reddit_mods, help:  {
          'reddit auth' => 'Start the OAuth2 authentication process for mod tools'
        })

        def authenticate(request)
          if base_url.nil? || base_url.empty?
            request.reply_privately('base_url must be set and must match reddit redirect uri base')
            return
          end
          url = 'https://www.reddit.com/api/v1/authorize'
          url += format('?client_id=%s', client_id)
          url += '&response_type=code'
          url += '&state=RANDOM_STRING'
          url += format('&redirect_uri=%s',
                        base_url + '/reddit_moderation/token')
          url += '&duration=permanent'
          url += format('&scope=%s', 'read,modposts')
          request.reply_privately(url)
        end

        http.get('/reddit_moderation/token', :get_auth_token)

        def get_auth_token(request, _response)
          target = Source.new(room: '##dosman711')
          robot.send_message(target, request.params['code'])
        end
      end
    end
    # Lita.register_handler(RedditModeration)
  end
end
