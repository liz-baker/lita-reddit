require "spec_helper"

describe Lita::Handlers::Reddit::RedditModeration, lita_handler: true,
         additional_lita_handlers: Lita::Handlers::Reddit do
         
  context "user has not authenticated" do
    it { is_expected.to route_command("reddit auth").with_authorization_for(:reddit_mods) }
    it { is_expected.not_to route_command("reddit auth") }
    
    it "should give error if base_url not set" do
      registry.config.robot.admins = user.id
      subject.robot.auth.add_user_to_group(user, user, :reddit_mods)
      send_command "reddit auth", as: user
      expect(replies.last).to start_with("base_url must be set")
    end
    it "should return oauth2 url if base_url is set" do
      registry.config.robot.admins = user.id
      subject.robot.auth.add_user_to_group(user, user, :reddit_mods)
      registry.config.handlers.reddit.mod.tap do |config|
        config.base_url = "http://localhost:8080"
      end
      send_command "reddit auth"
      expect(replies.last).to start_with("https://www.reddit.com")
    end
  end
end
