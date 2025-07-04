#require 'redis'

#$redis = Redis.new(
#  host: 'localhost',
#  port: 6379,
#  db: 0
#)

require 'redis'

redis_url = ENV["REDIS_URL"] || "redis://localhost:6379/0"
begin
$redis = Redis.new(
  url: ENV.fetch("REDIS_URL"),
  reconnect_attempts: 1,
  connect_timeout: 5,
  read_timeout: 5,
  write_timeout: 5
)

rescue URI::InvalidURIError => e
Rails.logger.error("Invalid REDIS_URL: #{e.message}")
end