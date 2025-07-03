#require 'redis'

#$redis = Redis.new(
#  host: 'localhost',
#  port: 6379,
#  db: 0
#)

require 'redis'

redis_url = ENV["REDIS_URL"] || "redis://localhost:6379/0"

$redis = Redis.new(url: redis_url)
