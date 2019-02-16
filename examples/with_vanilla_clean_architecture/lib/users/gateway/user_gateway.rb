module Users
  module Gateway
    class UserGateway
      attr_accessor :record_class

      def find_by_id(id)
        record = record_class.find_by(id: id)
        return if record.nil?

        Users::Domain::User.new(
          record.full_name,
          record.biography
        )
      end
    end
  end
end
