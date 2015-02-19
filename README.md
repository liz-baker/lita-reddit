# lita-reddit

A plugin that allows for watching the /new queue of a subreddit and posting new items to a chat room.

## Installation

Add lita-reddit to your Lita instance's Gemfile:

``` ruby
gem "lita-reddit"
```

## Configuration

``` ruby
# List of subreddit/channel to update pairs
config.handlers.reddit.reddits = [{subreddit: "subreddit_name", channel: "##channel_to_update"}]
# The client ID from the Reddit API
config.handlers.reddit.client_id = "client_from_api"
# The secret ID from the Reddit API
config.handlers.reddit.client_secret = "secret_from_api"
# The delay to wait before starting the polling in seconds (optional, defaults to 30s)
config.handlers.reddit.startup_delay = 30
# The interval in between requests (optional, defaults to 300s)
config.handlers.reddit.poll_interval = 300
```

## Usage

Add a collection of subreddit and channel pairs to the reddits array, create a script api key on reddit and enter those values, and then restart lita

## License

[MIT](http://opensource.org/licenses/MIT)
