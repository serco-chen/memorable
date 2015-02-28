# Memorable

A Rails logging system based on actions instead of model callbacks. Customizable ready-to-run configurations and built-in I18n support.

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

or ('journal' is the default name if not given one)

    $ rails g memorable:install

This command will create 4 files for you to start with:

1. `db/migration/20150228032852_create_memorable_journal.rb`
2. `app/models/journal.rb`
3. `config/initializers/memorable.rb`
4. `config/locales/memorable.en.yml`

Or you can manually setup as follows:

### Initializer

Write these lines of code to your configuration file, for example, `memorable.rb`.

```ruby
Memorable.setup do |config|
  config.journals_model = Journal

  # Specify template engine, default
  # config.template_engine = DefaultYAMLEngine
end
```

And put it under `config/initiailizers` directory of your Rails project.

Or require this file manually by yourself.

### Migration

Create a migration file as following:

```ruby
class CreateJournal < ActiveRecord::Migration
  def up
    create_table :journals do |t|
      t.integer :user_id
      t.integer :resource_id
      t.string  :resource_type
      t.text    :meta
      t.text    :content

      t.timestamps
    end

    add_index :journals, :user_id
    add_index :journals, :resource_id
  end

  def down
    remove_index :journals, :user_id
    remove_index :journals, :resource_id

    drop_table :journals
  end
end
```

And then execute:

    $ bundle exec rake db:migrate

This will give you a journals table.

### Model

Create a ActiveRecord Model, and you are all set.

```ruby
class Journal < ActiveRecord::Base
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
- resource_name # Use to detect resource in special case
- if, unless    # Add condition wheter to log or not
```

Add your own templates using yaml, this gem ships with a default yml template engine.

Put your templates under `config/locales` directory of you project, and name them with something like `memorable.en.yml`

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

As you can see, controller_name and action_name are used as the first two levels of template_keys.

And it support variable interpolation, default attributes, previous_changed attributes, controller_name, action_name, resource_type are included in default local variables.

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
