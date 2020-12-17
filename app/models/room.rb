class Room < ApplicationRecord
  before_create do
    tries = 3
    begin
      opentok = OpenTok::OpenTok.new('47001474', 'd8cb7942d6ce558196e6af111703ce7a9420de33')
      session = opentok.create_session media_mode: :routed
      self.vonage_session_id = session.session_id
      logger.debug 'opentok connected.'
    rescue Errno::ETIMEDOUT => e
      log.error e
      tries -= 1
      if tries.positive?
        logger.debug 'retrying opentok.new...'
        retry
      else
        logger.debug 'opentok.new timed out...'
        puts "ERROR: #{e.message}"
      end
    end
  end
end
