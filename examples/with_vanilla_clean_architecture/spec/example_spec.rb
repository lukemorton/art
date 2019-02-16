require_relative '../app/models/user'
require_relative '../lib/factory'

describe 'Vanilla Clean Architecture' do
  example 'using record, gateway and domain together' do
    user = Factory.new.active_record_user_gateway.find_by_id(1)
    expect(user.full_name).to eq('Luke Morton')
    expect(user.biography).to eq('He/Him')
  end

  example 'using domain' do
    user = Users::Domain::User.new('Luke Morton', 'He/Him')
    expect(user.full_name).to eq('Luke Morton')
    expect(user.biography).to eq('He/Him')
  end

  example 'using gateway' do
    user_gateway = Users::Gateway::UserGateway.new.tap do |g|
      g.record_class = double(
        find_by: double(full_name: 'Luke Morton', biography: 'He/Him'),
      )
    end

    user = user_gateway.find_by_id(1)
    expect(user.full_name).to eq('Luke Morton')
    expect(user.biography).to eq('He/Him')
  end
end
