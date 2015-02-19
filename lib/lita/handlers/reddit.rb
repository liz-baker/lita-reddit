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
      config :poll_interval, type: Integer, default: 300

      on :connected, :setup

      @@user_agent = 'ruby:lita-reddit:v0.0.6 (by /u/dosman711)'


      def setup(payload)
        after(config.startup_delay) do
          update_token
          refresh_posts
        end
        every (config.poll_interval) do
          refresh_posts
        end
        # update userless token once per hour
        every (3300) do
          update_token
        end
      end

      def update_token
        log.debug('updating userless oauth token')
        request = http
        request.basic_auth(config.client_id, config.client_secret)
        auth_response = request.post do |req|
          req.url 'https://www.reddit.com/api/v1/access_token'
          req.headers['User-Agent'] = @@user_agent
          req.body = 'grant_type=client_credentials'
        end
        response = MultiJson.load(auth_response.body)
        @@access_token = response['access_token']
      end

      def refresh_posts
        post_text = 'From /r/%s: %s (http://redd.it/%s)'
        base_redis_key = 'seen_list_%s_%s'
        config.reddits.each do |reddit|
          log.info('updating posts for /r/%s' % [reddit[:subreddit]])
          #new on the left
          redis_key = base_redis_key % [reddit[:channel], reddit[:subreddit]]
          post_limit = 3
          seen_reddits = redis.lrange(redis_key, 0, 10)
          request = http
          resp = request.get do |req|
            req.url 'https://oauth.reddit.com/r/%s/new' % [reddit[:subreddit]]
            req.headers['Authorization'] = 'bearer %s' % [@@access_token]
            req.headers['User-Agent'] = @@user_agent
            req.params['limit'] = post_limit
            req.params['before'] = redis.lindex(redis_key, 0)
          end
          log.info('result of request %s' % [resp.status])
          log.info(resp.body)
          response_body = MultiJson.load(resp.body)
          results = response_body['data']['children']
          log.info('count of results' % [results.length])
          target = Source.new(room: reddit[:channel])
          results.reverse.each do |post|
            if !seen_reddits.include?(post['data']['id']) then
              robot.send_message(target, post_text % [post['data']['subreddit'], post['data']['title'], post['data']['id']])
              redis.lpush(redis_key, post['data']['id'])
            end
            # keep a few extra around, 10 is still instantaneous
            redis.ltrim(redis_key, 0, 10)
          end
        end
      end 
    end

    Lita.register_handler(Reddit)
  end
end
