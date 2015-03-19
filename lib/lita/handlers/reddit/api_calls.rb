module Lita
  module Handlers
    class Reddit < Handler
      class ApiCalls < Handler
        def initialize(client_id, client_secret)
          @client_id = client_id
          @client_secret = client_secret
        end

        def user_agent
          "ruby:lita-reddit:v0.0.8 (by /u/dosman711)"
        end

        def update_token
          log.info("lita-reddit: updating userless auth token")
          request = http
          request.basic_auth(@client_id, @client_secret)
          auth_response = request.post do |req|
            req.url "https://www.reddit.com/api/v1/access_token"
            req.headers["User-Agent"] = user_agent
            req.body = "grant_type=client_credentials"
          end
          response = MultiJson.load(auth_response.body)
          @access_token = response["access_token"]
        rescue Exception => msg
          log.error("lita-reddit: Exception during token update: #{msg}")
        end

        def get_posts(subreddit, redis_key, limit = 3)
          resp = http.get do |req|
            req.url "https://oauth.reddit.com/r/#{subreddit}/new.json"
            req.headers["Authorization"] = "bearer #{@access_token}"
            req.headers["User-Agent"] = user_agent
            req.headers["Content-Type"] = "Application/json"
            req.params["limit"] = limit
            req.params["before"] = redis_key
          end
          response_body = MultiJson.load(resp.body)
          results = response_body["data"]["children"]
          results.collect do |r|
            {
              id: r["data"]["id"],
              subreddit: r["data"]["subreddit"],
              title: r["data"]["title"],
              user: r["data"]["author"],
              shortlink: format("http://redd.it/%s", r["data"]["id"])
            }
          end
        rescue Exception => msg
          log.error("lita-reddit: Exception during get_posts: #{msg}")
          return []
        end
      end
    end
  end
end
