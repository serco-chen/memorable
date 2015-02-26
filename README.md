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

      t.timestamps
    end

    add_index :journals, :user_id
    add_index :journals, :resource_id

    # If you are not using globalize, https://github.com/globalize/globalize,
    # comment this line and add a field named content into your journals table.
    # eg: t.text :content
    Journal.create_translation_table! :content => :text
  end

  def down
    remove_index :journals, :user_id
    remove_index :journals, :resource_id

    drop_table :journals

    # If you are not using globalize, comment this line
    Journal.drop_translation_table!
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
  attr_accessible :resource_id, :resource_type, :user_id, :meta, :content

  store :meta, accessors: [:controller, :action, :template_key ]

  # If you are not using globalize, comment this line
  translates :content, :fallbacks_for_empty_translations => true

  belongs_to :user
  belongs_to :resource, polymorphic: true, :touch => true
end
```

## Usage

Add your own templates using yaml, this gem ships with a default yml template engine.

Put your templates under `app/views/memorable` directory of you project, and name them with something like `en_US.yml`

Here's an example of a typical template file

```
defaults:
  create:
    base: "%{resource_type} created."
  update:
    base: "%{resource_type} updated."
  destroy:
    base: "%{resource_type} deleted."
  others:
    base: "%{action} was executed on %{resource_type}."
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
