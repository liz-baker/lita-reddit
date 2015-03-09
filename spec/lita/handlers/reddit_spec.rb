require "spec_helper"

describe Lita::Handlers::Reddit::SubredditPoster, lita_handler: true, additional_lita_handlers: Lita::Handlers::Reddit do
  it 'outputs new posts to the specified channels' do
    registry.config.handlers.reddit.tap do |config|
      config.client_id = "clientId"
      config.client_secret = "clientSecret"
      config.subreddit_poster.reddits = [{subreddit:"test", channel:"test"}]
    end
    allow(subject.client).to receive(:get_posts).and_return([{id: "post_id", subreddit: "test", title: "title"}])
    robot.trigger(:reddit_refresh_posts)
    expect(replies.last).to eq('From /r/test: title (http://redd.it/post_id)')
  end

  it 'does not output duplicate posts' do
    registry.config.handlers.reddit.tap do |config|
      config.client_id = "clientId"
      config.client_secret = "clientSecret"
      config.subreddit_poster.reddits = [{subreddit:"test", channel:"test"}]
    end
    allow(subject.client).to receive(:get_posts).and_return([{id: "post_id", subreddit: "test", title: "title"}])
    robot.trigger(:reddit_refresh_posts)
    robot.trigger(:reddit_refresh_posts)
    expect(replies.last).to eq('From /r/test: title (http://redd.it/post_id)')
    expect(replies.count).to be 1
  end
end

