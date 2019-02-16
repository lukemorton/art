# Art

Active Record Transformed.

**Status: Pre-alpha, not production ready**

## Concept

> Enabling developer productivity with ActiveRecord without the compromise on software quality

The Active Record pattern provides a fluid interface to all things database. This enables developer productivity by abstracting away SQL statements behind equivalent method calls, representing of database rows, and retrieving related data through associations.

If we take Rails for example, their implementation of ActiveRecord certainly doesn't follow the Single Responsibility Principle. In fact, a "model" in Rails can:

 - Create, Read, Update and Delete database records
 - Validate data with a validations engine
 - Relate associated tables together
 - Provide a fluid DSL abstraction for SQL

ActiveRecord out-of-the-box provides a huge interface that every model in your Rails application will inherit, literally. What if we could reduce this interface to something closer to a hand-carved gateway object.

### Reducing the surface area

Let's create a table and model in Rails. We're keeping it minimal for now.

``` ruby
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :full_name
      t.text :biography
      t.timestamps
    end
  end
end

class User < ActiveRecord::Base
end

user = User.create!(full_name: 'Luke Morton', biography: 'He/Him')
user.full_name # => 'Luke Morton'
user.biography # => 'He/Him'
user.save # => True
```

As you see, ActiveRecord enables you to create a record, access a record and save a record. This is a rather large surface area.

Let's take a single responsibility away from ActiveRecord and into a more simpler structure.

``` ruby
module Users
  module Domain
    User = Struct.new(:full_name, :biography)
  end
end

user = User.create!(full_name: 'Luke Morton', biography: 'He/Him')
simpler_user = Domain::User.new(user.full_name, user.biography)
simpler_user.full_name # => 'Luke Morton'
simpler_user.biography # => 'He/Him'
simpler_user.save # => NoMethodError
```

We now have a much simpler container for a single user's data. It can no longer save or do any other ActiveRecord magic.

### Querying via a gateway

Now what about querying logic? If we were going to reduce the surface area of logic that fetches data from a database, how would we do that?

``` ruby
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

user_gateway = Users::Gateway::UserGateway.new
user_gateway.record_class = User
user = user_gateway.find_by_id(1)
user.full_name # => 'Luke Morton'
user.biography # => 'He/Him'
user.save # => NoMethodError
```

We now have a gateway that interacts with the ActiveRecord `User` class but presents a much simpler interface, just one method `#find_by_id` that returns our simple domain object `Users::Domain::User`.

### Reducing boilerplate

Art provides tools to make it easier to create gateways around ActiveRecord.

``` ruby
module Users
  module Gateway
    class UserGateway
      include Art::Gateway::Interface

      expose(:find_by_id).with(:id).and_return(Users::Domain::User)
    end
  end
end
```

We define an interface by including `Art::Gateway::Interface` and defining what methods we want any gateway of type `Users::Gateway::UserGateway` to expose. You may find some of this syntax similar to RSpec Mocks.

We now need an ActiveRecord implementation of this gateway.

``` ruby
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
```

Our `Users::Gateway::ActiveRecordUserGateway` implements the interface defined in `Users::Gateway::UserGateway`. It however does not need to contain any logic for wrapping ActiveRecord in a domain object. The responsibility of this class is to map ActiveRecord to a simpler gateway interface and that's it.

``` ruby
user_gateway =  Users::Gateway::UserGateway[Users::Gateway::ActiveRecordUserGateway].new(::User)
user = gateway.find_by_id(1)
user.full_name # => 'Luke Morton'
user.biography # => 'He/Him'
user.save # => NoMethodError
```

We then combine the interface with the ActiveRecord implementation, and then initialise the gateway. We now can call `#find_by_id` and have a simple domain object returned, as per the definition in `Users::Gateway::UserGateway`.

### Summary

By defining domain objects, gateway interfaces and implementation specific gateways we reduce the surface area of ActiveRecord and therefore get the benefits of looser coupling between our application, domain logic and ActiveRecord making software easier to change in future.

## Going further

This is so far an idea with a tiny prototypal implementation. Check out an [Art example with tests](examples/with_art_simple_gateway) and also the [dodgy implementation](lib/art.rb).

I'm unsure if the benefit of using something like Art is worth the additional learning overhead compared with hand rolling gateways as per the example [vanilla example](examples/with_vanilla_clean_architecture).
