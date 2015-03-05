class ApiCalls
  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret
  end

  def user_agent
    'ruby:lita-reddit:v0.0.7 (by /u/dosman711)'
  end

  def update_token(request)
    request.basic_auth(@client_id, @client_secret)
    auth_response = request.post do |req|
      req.url 'https://www.reddit.com/api/v1/access_token'
      req.headers['User-Agent'] = user_agent
      req.body = 'grant_type=client_credentials'
    end
    response = MultiJson.load(auth_response.body)
    @access_token = response['access_token']
  end

  def get_posts(request, subreddit, redis_key)
    resp = request.get do |req|
      req.url 'https://oauth.reddit.com/r/%s/new.json' % [subreddit]
      req.headers['Authorization'] = 'bearer %s' % [@access_token]
      req.headers['User-Agent'] = user_agent
      req.headers['Content-Type'] = 'Application/json'
      req.params['limit'] = 3
      req.params['before'] = redis_key
    end
    response_body = MultiJson.load(resp.body)
    results = response_body['data']['children']
    results.collect {|r| 
      {
        id: r['data']['id'], 
        subreddit: r['data']['subreddit'], 
        title: r['data']['title']
      }}
  end
end
