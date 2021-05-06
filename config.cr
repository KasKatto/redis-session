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