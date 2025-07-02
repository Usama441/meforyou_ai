class TopicNamer
  def self.generate(user, message)
    prompt = <<~PROMPT
      Summarize the user's intent in a short 3-word topic title.

      Message: "#{message}"
      Only return the title. No punctuation.
    PROMPT

    AgenticAI.new(user).call_llm(prompt).strip
  end
end
