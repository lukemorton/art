module Users
  module Gateway
    class ActiveRecordUserGateway
      attr_accessor :record_class

      def find_by_id(id)
        record_class.find_by(id: id)
      end
    end
  end
end
