require_relative 'users/domain/user'
require_relative 'users/gateway/user_gateway'
require_relative 'users/gateway/active_record_user_gateway'

class Factory
  def active_record_user_gateway
    Users::Gateway::UserGateway[Users::Gateway::ActiveRecordUserGateway].new(::User)
  end
end
