class Summarizer
  def initialize(user, session_id)
    @memory = RedisMemoryManager.new(user, session_id)
  end

  def summarize
    history = @memory.full_history.map { |m| "#{m['role']}: #{m['content']}" }.join("\n")
    prompt = "Summarize the following chat:\n#{history}"

    summary = AgenticAI.new(@memory.user).call_llm(prompt)
    $redis.set("summary:user:#{@memory.user.id}:session:#{@memory.session_id}", summary)
  end
end
