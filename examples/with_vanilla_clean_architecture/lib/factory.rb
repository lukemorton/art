require_relative 'users/domain/user'
require_relative 'users/gateway/user_gateway'

class Factory
  def active_record_user_gateway
    Users::Gateway::UserGateway.new.tap do |g|
      g.record_class = ::User
    end
  end
end
