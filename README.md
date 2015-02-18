# lita-reddit

A plugin that allows for watching the /new queue of a subreddit and posting new items to a chat room.

## Installation

Add lita-reddit to your Lita instance's Gemfile:

``` ruby
gem "lita-reddit"
```

## Configuration

config.handlers.reddit.reddits = [{subreddit: "subreddit_name", channel: "##channel_to_update"}]
config.handlers.reddit.client_id = "client_from_api"
config.handlers.reddit.client_secret = "secret_from_api"
config.handlers.reddit.poll_interval = 300 #optional, default 300 (seconds)

## Usage

Add a collection of subreddit and channel pairs to the reddits array, create a script api key on reddit and enter those values, and then restart lita

## License

[MIT](http://opensource.org/licenses/MIT)
