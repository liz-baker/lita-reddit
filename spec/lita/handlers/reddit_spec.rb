require "spec_helper"

describe Lita::Handlers::Reddit::SubredditPoster,
         lita_handler: true,
         additional_lita_handlers: Lita::Handlers::Reddit do
  before :each do
    registry.config.handlers.reddit.tap do |config|
      config.client_id = "clientId"
      config.client_secret = "clientSecret"
    end
    @standard_response = [{
        id: "post_id",
        subreddit: "test",
        title: "title",
        user: "user",
        shortlink: "http://redd.it/post_id"
      }]
    allow(described_class).to receive(:new).and_return(subject)
  end
  it "outputs new posts to the specified channels" do
    registry.config.handlers.reddit.tap do |config|
      config.reddits = [{ subreddit: "test", channel: "test" }]
    end
    allow(subject.client).to receive(:get_posts).and_return(@standard_response)
    robot.trigger(:reddit_refresh_posts)
    expect(replies.last).to eq("/u/user: title | /r/test | http://redd.it/post_id")
  end

  it "does not output duplicate posts" do
    registry.config.handlers.reddit.tap do |config|
      config.reddits = [{ subreddit: "test", channel: "test" }]
    end
    allow(subject.client).to receive(:get_posts).and_return(@standard_response)
    robot.trigger(:reddit_refresh_posts)
    robot.trigger(:reddit_refresh_posts)
    expect(replies.last).to eq("/u/user: title | /r/test | http://redd.it/post_id")
    expect(replies.count).to be 1
  end

  it "still posts if there is an error during retrieval" do
    registry.config.handlers.reddit.tap do |config|
      config.reddits = [{ subreddit: "test", channel: "test" }]
    end
    allow(subject.client).to receive(:get_posts).and_raise(RuntimeError)
    robot.trigger(:reddit_refresh_posts)
    allow(subject.client).to receive(:get_posts).and_return(@standard_response)
    robot.trigger(:reddit_refresh_posts)
    expect(replies.last).to eq("/u/user: title | /r/test | http://redd.it/post_id")
    expect(replies.count).to be 1
  end

  it "handles exception during update_token" do
    allow(subject.client).to receive(:update_token).and_raise(RuntimeError)
    expect { subject.update_token(nil) }.not_to raise_error
  end

  it "unescapes escaped html text" do
    response = [{
      id: "post_id",
      subreddit: "test",
      title: "This &amp; that, these &amp; those",
      user: "user",
      shortlink: "http://redd.it/post_id"
    }]
    registry.config.handlers.reddit.tap do |config|
      config.reddits = [{ subreddit: "test", channel: "test" }]
    end
    allow(subject.client).to receive(:get_posts).and_return(response)
    robot.trigger(:reddit_refresh_posts)
    expect(replies.last).to eq("/u/user: This & that, these & those | /r/test | http://redd.it/post_id")
  end
end
