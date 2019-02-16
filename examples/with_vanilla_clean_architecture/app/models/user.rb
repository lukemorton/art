require 'active_model'

# A pretend ActiveRecord model
#
class User
  include ActiveModel::Model

  def self.find_by(id:)
    new(id: 1, full_name: 'Luke Morton', biography: 'He/Him')
  end

  attr_accessor :id
  attr_accessor :full_name
  attr_accessor :biography
end
