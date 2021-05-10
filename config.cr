RedisSession.configure do |settings|
  # Sets the name for the session id cookie
  settings.session_id_name = "_session"
  # Sets the id length
  settings.session_id_length = 32
  # Should session storage be encrypted? (redis does not support encryption at rest - unless your using a cloud service like Redis Cloud or AWS)
  settings.encrpyt_session_storage = false
  # Sets how long a session will idle before being removed (idle timer reset every time session is written or read)
  settings.session_idle_time = 60.minutes
  # URI to redis server -
  settings.redis_uri = "redis://localhost:6379/0"
end
