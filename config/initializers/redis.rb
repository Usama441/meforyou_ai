#require 'redis'

#$redis = Redis.new(
#  host: 'localhost',
#  port: 6379,
#  db: 0
#)

require 'redis'

redis_url = ENV["REDIS_URL"] || "redis://localhost:6379/0"
$redis = Redis.new(url: redis_url,
                   reconnect_attempts: 1,
                   connect_timeout: 5,
                   read_timeout: 5,
                   write_timeout: 5)
