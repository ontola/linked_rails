# RailsLD
Rails LD aims to make creating a basic Linked Data application a matter of seconds.

It includes:
* Linked data serialization using [rdf-serializers](https://github.com/ontola/rdf-serializers)
* Controller abstraction using [active_response](https://github.com/ontola/active_response)
* Serialization of forms using the [SHACL spec](http://www.w3.org/ns/shacl)
* Serialization of collections using the [Activity Streams spec](https://www.w3.org/ns/activitystreams)
* Serialization of menus
* Communicating actions to be executed by the frontend using Exec Actions header
* Rendering errors as RDF
* Parsing linked data graphs as params

## Work in progress
This gem is an extraction from an existing app. Tests are not yet sufficient but will be extended soon.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails_ld'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install rails_ld
```

## Getting started

Add the following lines to application.rb to enable params parsing
```
require 'rails_ld/middleware/linked_data_params'

module MyApp
  class Application < Rails::Application
    [...]
    config.middleware.use RailsLD::Middleware::LinkedDataParams
    [...]
  end
end
```

Add the following line to your models
```
RailsLD::Model
```

Add the following line to your controllers
```
RailsLD::Controller
```

Add the following line to your serializers
```
RailsLD::Serializer
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
