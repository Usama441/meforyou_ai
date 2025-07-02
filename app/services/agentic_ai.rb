require 'net/http'
require 'json'

class AgenticAi
  def initialize(user, session_id = "default")
    @user = user
    @session_id = session_id
    @memory = RedisMemoryManager.new(user, session_id)
  end

  def call_llm(current_input)
    prompt = build_prompt_with_memory(current_input)

    uri = URI("http://localhost:11434/api/generate")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, { 'Content-Type': 'application/json' })

    req.body = {
      model: "mistral",
      prompt: prompt,
      stream: false
    }.to_json

    response = http.request(req)
    json = JSON.parse(response.body) rescue {}
    json["response"] || "[AgenticAI Error: Invalid response]"
  end

  def build_prompt_with_memory(current_input)
    persona = PersonaManager.new(@user).all.map { |k,v| "#{k}: #{v}" }.join("\n")
    history = @memory.get_history(20).map { |m| "#{m['role']}: #{m['content']}" }.join("\n")

    "Persona:\n#{persona}\n\nConversation:\n#{history}\n\nUser: #{current_input}\nAI:"
  end
end
