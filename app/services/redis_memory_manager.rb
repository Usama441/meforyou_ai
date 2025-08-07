# services/redis_memory_manager.rb
require 'redis'
require 'json'

class RedisMemoryManager
  attr_reader :user, :session_id

  def initialize(user, session_id = "default")
    @user = user
    @session_id = session_id
    @redis = Redis.new

    @chat_key = "memory:user:#{@user.id}:session:#{@session_id}:chat"
    @facts_key = "memory:user:#{@user.id}:facts"
    @persona_key = "memory:user:#{@user.id}:persona"
  end

  # 🔹 Store a chat message
  def store_message(role, content)
    entry = { role: role, content: content, timestamp: Time.now.to_i }.to_json
    @redis.rpush(@chat_key, entry)
  end

  # 🔹 Retrieve recent messages
  def get_history(limit = 20)
    raw = @redis.lrange(@chat_key, -limit, -1)
    raw.map { |json| JSON.parse(json) }
  end

  # 🔹 Retrieve full chat history
  def all_history
    raw = @redis.lrange(@chat_key, 0, -1)
    raw.map { |json| JSON.parse(json) }
  end

  # 🔹 Clear all chat
  def clear_chat
    @redis.del(@chat_key)
  end

  def chat_length
    @redis.llen(@chat_key)
  end

  # 🔹 Store summarized conversation
  def summarize_and_trim(keep_last = 10)
    history = get_history(100)
    return if history.empty?

    summary = "Summary:\n" + history.map { |m| "#{m['role']}: #{m['content']}" }.join("\n")
    clear_chat
    store_message("system", summary)
    keep_last.times do |i|
      m = history[-keep_last + i]
      store_message(m['role'], m['content']) if m
    end
  end

  # 🧠 Long-term memory (facts about user)
  def store_fact(key, value)
    facts = get_facts
    facts[key] = value
    @redis.set(@facts_key, facts.to_json)
  end

  def get_fact(key)
    get_facts[key]
  end

  def get_facts
    json = @redis.get(@facts_key)
    json ? JSON.parse(json) : {}
  end

  def clear_facts
    @redis.del(@facts_key)
  end

  # 🎭 Persona memory
  def set_persona(persona_name)
    @redis.set(@persona_key, persona_name)
  end

  def get_persona
    @redis.get(@persona_key) || "default"
  end

  def clear_persona
    @redis.del(@persona_key)
  end
end
