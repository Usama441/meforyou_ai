# app/services/redis_memory_service.rb
require 'json'

class RedisMemoryService
  MAX_MESSAGES = 20
  REDIS_KEY_PREFIX = "conversation".freeze

  def initialize(conversation_id)
    @key = "#{REDIS_KEY_PREFIX}:#{conversation_id}:memory"
  end

  def all_messages
    raw = redis.get(@key)
    raw ? JSON.parse(raw) : []
  end

  def add_message(role:, content:)
    messages = all_messages

    messages << { role: role, content: content }

    if messages.length > MAX_MESSAGES
      messages = summarize_messages(messages)
    end

    redis.set(@key, messages.to_json)
  end

  def get_prompt_context
    all_messages.map { |msg| "#{msg['role'].capitalize}: #{msg['content']}" }.join("\n")
  end

  def reset!
    redis.del(@key)
  end

  private

  def summarize_messages(messages)
    # Keep the first few, summarize middle, keep last one
    head = messages.first(5)
    tail = messages.last(1)

    summary_content = <<~SUMMARY.strip
      This is a summary of earlier conversation:
      #{head.map { |m| "#{m['role'].capitalize}: #{m['content']}" }.join("\n")}
      ...
    SUMMARY

    summary = { role: "system", content: summary_content }

    head + [summary] + tail
  end

  def redis
    @redis ||= Redis.new
  end
end
