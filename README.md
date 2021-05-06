# redis-session
A Crystal shard for Lucky framework to enable session storage in redis

A very hacky solution that should "just work".

## How to use
Add to shards.yml
```yml
redis-session:
  github: kaskatto/redis-session
 ```
 Then run 
 ```cmd
 shards install
 ```
 The post install script should run automnatically and set things up.
 
 **Note** This script replaces core lucky framework files. It does create a backup before hand, should things go wrong - just keep that in mind.
 
 After the script finishes add the following to your shards.cr
 ```crystal
 require "redis-session"
 ```
 
 There is a config file as well allowing you to customise how redis-session works. It is included by default. To utilise it you should move it to your config folder (if its not already there.) Below is the config example:
 ```crystal
 RedisSession.configure do |settings|
  # Sets the name for the session id cookie
  setting session_id_name : String = "_session"
  # Sets the id length
  setting session_id_length : Int32 = 32
  # Should session storage be encrypted? (redis does not support encryption at rest - unless your using a cloud service like Redis Cloud or AWS)
  setting encrpyt_session_storage : Bool = false
  # Sets how long a session will idle before being removed (idle timer reset every time session is written or read)
  setting session_idle_time : Time::Span = 60.minutes
  # URI to redis server -
  setting redis_uri : String = "redis://localhost:6379"
end
```
