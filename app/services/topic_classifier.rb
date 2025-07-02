# app/services/topic_classifier.rb
class TopicClassifier
  def self.new_topic?(user, message)
    memory = RedisMemoryManager.new(user)
    history = memory.get_history(5) # last few messages
    context = history.map { |m| "#{m['role']}: #{m['content']}" }.join("\n")

    prompt = <<~PROMPT
      Here is the recent conversation:
      #{context}

      Now the user said: "#{message}"

      Does this message start a new topic, or is it a continuation?
      Answer only: "new topic" or "continuation"
    PROMPT

    response = AgenticAi.new(user).call_llm(prompt)
    response.downcase.include?("new topic")
  rescue => e
    Rails.logger.error("Topic detection failed: #{e.message}")
    false
  end
end
