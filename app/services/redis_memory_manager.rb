# app/services/redis_memory_manager.rb
require 'redis'

class RedisMemoryManager
  def initialize(user, session_id = "default")
    @user = user
    @session_id = session_id
    @key = "memory:user:#{@user.id}:session:#{@session_id}"
    @redis = Redis.new
  end

  def store_message(role, content)
    entry = { role: role, content: content, timestamp: Time.now.to_i }.to_json
    @redis.rpush(@key, entry)
  end

  def get_history(limit = 20)
    raw = @redis.lrange(@key, -limit, -1)
    raw.map { |json| JSON.parse(json) }
  end

  def all_history
    raw = @redis.lrange(@key, 0, -1)
    raw.map { |json| JSON.parse(json) }
  end

  def clear
    @redis.del(@key)
  end

  def length
    @redis.llen(@key)
  end

  def summarize_and_trim(keep_last = 10)
    history = get_history(100)
    summary = "Summary of conversation:\n" + history.map { |m| "#{m['role']}: #{m['content']}" }.join("\n")
    clear
    store_message("system", summary)
    keep_last.times do |i|
      store_message(history[-keep_last + i]['role'], history[-keep_last + i]['content']) if history[-keep_last + i]
    end
  end
end
