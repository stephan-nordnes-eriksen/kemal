require "base64"

module Kemal::Middleware
  # This middleware adds HTTP Basic Auth support to your application.
  # Returns 401 "Unauthorized" with wrong credentials.
  #
  # auth_handler = Kemal::Middleware::HTTPBasicAuth.new("username", "password")
  # Kemal.config.add_handler auth_handler
  #
  class HTTPBasicAuth < HTTP::Handler
    BASIC = "Basic"
    AUTH  = "Authorization"

    def initialize(@username, @password)
    end

    def call(request)
      if request.headers[AUTH]?
        if value = request.headers[AUTH]
          if value.size > 0 && value.starts_with?(BASIC)
            return call_next(request) if authorized?(value)
          end
        end
      end
      headers = HTTP::Headers.new
      headers["WWW-Authenticate"] = "Basic realm=\"Login Required\""
      HTTP::Response.new(401, "Could not verify your access level for that URL.\nYou have to login with proper credentials", headers, nil, "HTTP/1.1", nil)
    end

    def authorized?(value)
      username, password = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")
      @username == username && @password == password
    end
  end
end