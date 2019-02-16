module Users
  module Gateway
    class UserGateway
      include Art::Gateway::Interface

      expose(:find_by_id).with(:id).and_return(Users::Domain::User)
    end
  end
end
