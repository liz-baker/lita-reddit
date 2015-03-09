require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/reddit"
require "lita/handlers/reddit/base"
require "lita/handlers/reddit/subreddit_poster"
require "lita/handlers/reddit/reddit_moderation"

Lita::Handlers::Reddit.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
