module Lita
  module Handlers
    class Reddit < Handler
      class ModqueuePoster < Base
        namespace "reddit"
      end
      Lita.register_handler(ModqueuePoster)
    end
  end
end
