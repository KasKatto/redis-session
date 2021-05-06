module RedisSession
  Habitat.create do 
    setting session_id_name : String = "_session"
    setting session_id_length : Int32 = 32
    # setting lock_session_to_ip : Bool = false
    setting encrpyt_session_storage : Bool = false
    setting session_idle_time : Time::Span = 60.minutes
    setting redis_uri : String = "redis://localhost:6379"
  end

  def self.read_session(cookie_jar : Lucky::CookieJar) : String | Nil
    redis = Redis::Client.new(URI.parse(RedisSession.settings.redis_uri))
    if Lucky::ForceSSLHandler.settings.enabled
      cookiePrefix = "__Host-"
    else
      cookiePrefix = ""
    end
    session_name = cookiePrefix + RedisSession.settings.session_id_name
    session_id = cookie_jar.get?(session_name)

    session_id ||= ""

    if session_id == "" || redis.exists(session_id) == 0
      session_id = Random::Secure.urlsafe_base64(RedisSession.settings.session_id_length)
      cookie_jar.set(session_name, session_id).secure(true).http_only(true).samesite(:strict)
    else
      storedSession = redis.get(session_id)
      if RedisSession.settings.encrpyt_session_storage
        storedSession ||= ""
        if storedSession != ""
          storedSession = decrypt(storedSession)   
        end
      end
      
    end

    redis.run({"expire", "#{session_id}", "#{RedisSession.settings.session_idle_time.total_seconds.to_i}"})
    storedSession
  end

  def self.write_session(context : HTTP::Server::Context) : Void
    redis = Redis::Client.new(URI.parse(RedisSession.settings.redis_uri))
    if Lucky::ForceSSLHandler.settings.enabled
      cookiePrefix = "__Host-"
    else
      cookiePrefix = ""
    end

    session_name = cookiePrefix + RedisSession.settings.session_id_name
    session_id = context.cookies.get(session_name)

    if RedisSession.settings.encrpyt_session_storage
      sessionToStore = encrypt(context.session.to_json)
    else 
      sessionToStore = context.session.to_json
    end

    redis.set session_id, sessionToStore, ex: RedisSession.settings.session_idle_time.total_seconds.to_i
  end

  def self.encrypt(raw_value : String) : String
    value = Base64.strict_encode(encryptor.encrypt(raw_value))
  end

  def self.decrypt(raw_value : String) : String
    String.new(encryptor.decrypt(Base64.decode(raw_value)))
  end

  @@encryptor : Lucky::MessageEncryptor?

  def self.encryptor : Lucky::MessageEncryptor
    @@encryptor ||= Lucky::MessageEncryptor.new(secret_key)
  end

  def self.secret_key : String
    Lucky::Server.settings.secret_key_base
  end
end
  