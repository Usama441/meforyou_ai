# app/jobs/agent_response_job.rb

class AgentResponseJob < ApplicationJob
  queue_as :default

  def perform(user_id, user_message)
    memory_key = "memory:user:#{user_id}"
    memory = $redis.get(memory_key) || "No memory yet"

    prompt = <<~PROMPT
      User: #{user_message}
      Memory: #{memory}
      Respond as helpful AI agent.
    PROMPT

    # Call your local AI API (e.g., Mistral via Ollama or Groq)
    response = call_local_ai(prompt)

    # Save latest memory (example logic)
    $redis.set(memory_key, "#{memory}\nUser: #{user_message}\nAI: #{response}")

    # Optional: Save last response for frontend polling
    $redis.set("last_response:user:#{user_id}", response)
  end

  private

  def call_local_ai(prompt)
    uri = URI.parse("http://localhost:11434/api/generate")
    headers = { "Content-Type" => "application/json" }
    body = {
      model: "mistral",  # or llama3
      prompt: prompt,
      stream: false
    }

    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, headers)
    req.body = body.to_json

    res = http.request(req)
    json = JSON.parse(res.body)
    json["response"]
  rescue => e
    "Error calling AI: #{e.message}"
  end
end
