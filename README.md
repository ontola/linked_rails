# LinkedRails
LinkedRails is a gem for Ruby on Rails that helps you create a Linked Data application in a matter of seconds.

It includes among other things:
* Linked data serialization to Turtle, JSON-LD, N-Triples and more using [rdf-serializers](https://github.com/ontola/rdf-serializers)
* Controller abstraction using [active_response](https://github.com/ontola/active_response)
* Serialization of forms
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
gem 'linked_rails'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install linked_rails
```

## Getting started

Add the following lines to application.rb to enable params parsing
```
require 'linked_rails/middleware/linked_data_params'

module MyApp
  class Application < Rails::Application
    [...]
    config.middleware.use LinkedRails::Middleware::LinkedDataParams
    [...]
  end
end
```

Add the following line to your models
```
LinkedRails::Model
```

Add the following line to your controllers
```
LinkedRails::Controller
```

Add the following line to your serializers
```
LinkedRails::Serializer
```

Add the following line to your policies
```
LinkedRails::Policy
```
