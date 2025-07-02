# app/services/persona_manager.rb
class PersonaManager
  def initialize(user)
    @user = user
    @redis = Redis.new
    @key = "persona:user:#{user.id}"
  end

  def set(attribute, value)
    @redis.hset(@key, attribute, value)
  end

  def get(attribute)
    @redis.hget(@key, attribute)
  end

  def all
    @redis.hgetall(@key)
  end

  def clear
    @redis.del(@key)
  end
end
