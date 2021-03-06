# Memorable

A Rails logging system based on actions instead of model callbacks with minimum configurations and built-in I18n support.

**Note**
It's released on [RubyGems](https://rubygems.org/gems/memorable).
If something doesn't work, feel free to report a bug or start an issue.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'memorable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install memorable

If you prefer to use the latest code, you can build from source:

```
gem build memorable.gemspec
gem install memorable-<VERSION>.gem
```

## Configuration

run:

    $ rails g memorable:install MODELNAME

or

    $ rails g memorable:install

('activity_log' is the default name if not given one)

This command will create 4 files for you to start with:

1. `db/migration/20150228032852_create_memorable_activity_logs.rb`
2. `app/models/activity_log.rb`
3. `config/initializers/memorable.rb`
4. `config/locales/memorable.en.yml`

Or you can manually setup as follows:

### Initializer

Write these lines of code to your configuration file, for example, `memorable.rb`.

```ruby
Memorable.setup do |config|
  config.log_model = "ActivityLog"

  # Specify template engine, default
  # config.template_engine = DefaultYAMLEngine
end
```

And put it under `config/initiailizers` directory of your Rails project.

Or require this file manually by yourself.

### Migration

Create a migration file as following:

```ruby
class CreateActivityLog < ActiveRecord::Migration
  def up
    create_table :activity_logs do |t|
      t.integer :user_id
      t.integer :resource_id
      t.string  :resource_type
      t.text    :meta
      t.text    :content

      t.timestamps
    end

    add_index :activity_logs, :user_id
    add_index :activity_logs, :resource_id
  end

  def down
    remove_index :activity_logs, :user_id
    remove_index :activity_logs, :resource_id

    drop_table :activity_logs
  end
end
```

And then execute:

    $ bundle exec rake db:migrate

This will give you a activity_logs table.

### Model

Create a ActiveRecord Model, and you are all set.

```ruby
class ActivityLog < ActiveRecord::Base
  include Memorable::Model

  attr_accessible :resource_id, :resource_type, :user_id, :meta, :content

  store :meta

  belongs_to :user
  belongs_to :resource, polymorphic: true, :touch => true
end
```

## Usage

Specify which actions you would like to log:

```ruby
class ContactsController < ApplicationController
  memorize :only => [:create, :update]
end
```

`memorize` method support following options:

```
- only, except  # It's used to specify action names to log
- resource_name # Use to detect resource in special cases
- if, unless    # Add conditions whether to log or not
```

Then put your templates under `config/locales` directory of you project, and name it with something like `memorable.en.yml`.

Here's an example of a typical template file

```
en:
  memorable:
    defaults:
      create:
        base: "%{resource_type} %{resource_id} created."
      update:
        base: "%{resource_type} %{resource_id} updated."
      destroy:
        base: "%{resource_type} %{resource_id} deleted."

    contacts:
      create:
        base:  "Added vendor %{name} to Vendor Library."
      update:
        base: "Edited information for Vendor %{name}."
        name: "Change Vendor Name form %{previous_name} to %{name}."
      destroy:
        base: "Deleted Vendor %{name}."
```

And it support variable interpolation, default attributes, previous_changed attributes, resource_type are included in default local variables.

## Advanced Usage

You can pass addition local variables used in template interpolation, or even specify which template you would like to use.

You can achieve this by define a method named `"memorable_#{action_name}"` in your controller and return a hash with additional local variables and template_key you would like to use.

```ruby
class ContactsController < ApplicationController

  private

    def memorable_update
      if @contact.previous_changes.key? :name
        {template_key: 'name', company_email: @contact.company.email}
      end
    end
end
```
