#require 'redis'

#$redis = Redis.new(
#  host: 'localhost',
#  port: 6379,
#  db: 0
#)

require 'redis'

if ENV["REDIS_URL"]
  $redis = Redis.new(url: ENV["REDIS_URL"])
else
  $redis = Redis.new(
    host: 'localhost',
    port: 6379,
    db: 0
  )
end