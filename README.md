# Mutations

[![Build Status](https://travis-ci.org/cypriss/mutations.svg?branch=master)](https://travis-ci.org/cypriss/mutations)
[![Code Climate](https://codeclimate.com/github/cypriss/mutations.svg)](https://codeclimate.com/github/cypriss/mutations)

Compose your business logic into commands that sanitize and validate input. Write safe, reusable, and maintainable code for Ruby and Rails apps.

## Installation

    gem install mutations

Or add it to your Gemfile:

    gem 'mutations'

## Example

```ruby
# Define a command that signs up a user.
class UserSignup < Mutations::Command

  # These inputs are required
  required do
    string :email, matches: EMAIL_REGEX
    string :name
  end

  # These inputs are optional
  optional do
    boolean :newsletter_subscribe
  end

  # The execute method is called only if the inputs validate. It does your business action.
  def execute
    user = User.create!(inputs)
    NewsletterSubscriptions.create(email: email, user_id: user.id) if newsletter_subscribe
    UserMailer.async(:deliver_welcome, user.id)
    user
  end
end

# In a controller action (for instance), you can run it:
def create
  outcome = UserSignup.run(params[:user])

  # Then check to see if it worked:
  if outcome.success?
    render json: {message: "Great success, #{outcome.result.name}!"}
  else
    render json: outcome.errors.symbolic, status: 422
  end
end
```

Some things to note about the example:

* We don't need attr_accessible or strong_attributes to protect against mass assignment attacks
* We're guaranteed that within execute, the inputs will be the correct data types, even if they needed some coercion (all strings are stripped by default, and strings like "1" / "0" are converted to true/false for newsletter_subscribe)
* We don't need ActiveRecord validations
* We don't need callbacks on our models -- everything is in the execute method (helper methods are also encouraged)
* We don't use accepts_nested_attributes_for, even though multiple ActiveRecord models are created
* This code is completely re-usable in other contexts (need an API?)
* The inputs to this 'function' are documented by default -- the bare minimum to use it (name and email) are documented, as are 'extras' (newsletter_subscribe)

## Why is it called 'mutations'?

Imagine you had a folder in your Rails project:

    app/mutations

And inside, you had a library of business operations that you can do against your datastore:

    app/mutations/users/signup.rb
    app/mutations/users/login.rb
    app/mutations/users/update_profile.rb
    app/mutations/users/change_password.rb
    ...
    app/mutations/articles/create.rb
    app/mutations/articles/update.rb
    app/mutations/articles/publish.rb
    app/mutations/articles/comment.rb
    ...
    app/mutations/ideas/upsert.rb
    ...

Each of these _mutations_ takes your application from one state to the next.

That being said, you can create commands for things that don't mutate your database.

## How do I call mutations?

You have two choices. Given a mutation UserSignup, you can do this:

```ruby
outcome = UserSignup.run(params)
if outcome.success?
  user = outcome.result
else
  render outcome.errors
end
```

Or, you can do this:

```ruby
user = UserSignup.run!(params) # returns the result of execute, or raises Mutations::ValidationException
```

## What can I pass to mutations?

Mutations only accept hashes as arguments to #run and #run!

That being said, you can pass multiple hashes to run, and they are merged together. Later hashes take precedence. This give you safety in situations where you want to pass unsafe user inputs and safe server inputs into a single mutation. For instance:

```ruby
# A user comments on an article
class CreateComment < Mutations::Command
  required do
    model :user
    model :article
    string :comment, max_length: 500
  end

  def execute; ...; end
end

def somewhere
  outcome = CreateComment.run(params[:comment],
    user: current_user,
    article: Article.find(params[:article_id])
  )
end
```

Here, we pass two hashes to CreateComment. Even if the params[:comment] hash has a user or article field, they're overwritten by the second hash. (Also note: even if they weren't, they couldn't be of the correct data type in this particular case.)

## How do I define mutations?

1. Subclass Mutations::Command

    ```ruby
    class YourMutation < Mutations::Command
      # ...
    end
    ```

2. Define your required inputs and their validations:

    ```ruby
    required do
      string :name, max_length: 10
      symbol :state, in: %i(AL AK AR ... WY)
      integer :age
      boolean :is_special, default: true
      model :account
    end
    ```

3. Define your optional inputs and their validations:

    ```ruby
    optional do
      array :tags, class: String
      hash :prefs do
        boolean :smoking
        boolean :view
      end
    end
    ```

4. Define your execute method. It can return a value:

    ```ruby
    def execute
      record = do_thing(inputs)
      # ...
      record
    end
    ```

See a full list of options [here](https://github.com/cypriss/mutations/wiki/Filtering-Input).

## How do I write an execute method?

Your execute method has access to the inputs passed into it:

```ruby
self.inputs # white-listed hash of all inputs passed to run.  Hash has indifferent access.
```

If you define an input called _email_, then you'll have these three methods:

```ruby
self.email           # Email value passed in
self.email=(val)     # You can set the email value in execute. Rare, but useful at times.
self.email_present?  # Was an email value passed in? Useful for optional inputs.
```

You can do extra validation inside of execute:

```ruby
if email =~ /aol.com/
  add_error(:email, :old_school, "Wow, you still use AOL?")
  return
end
```

You can return a value as the result of the command:

```ruby
def execute
  # ...
  "WIN!"
end

# Get result:
outcome = YourMutuation.run(...)
outcome.result # => "WIN!"
```

## What about validation errors?

If things don't pan out, you'll get back an Mutations::ErrorHash object that maps invalid inputs to either symbols or messages. Example:

```ruby
# Didn't pass required field 'email', and newsletter_subscribe is the wrong format:
outcome = UserSignup.run(name: "Bob", newsletter_subscribe: "Wat")

unless outcome.success?
  outcome.errors.symbolic # => {email: :required, newsletter_subscribe: :boolean}
  outcome.errors.message # => {email: "Email is required", newsletter_subscribe: "Newsletter Subscription isn't a boolean"}
  outcome.errors.message_list # => ["Email is required", "Newsletter Subscription isn't a boolean"]
end
```

You can add errors in a validate method if the default validations are insufficient. Errors added by validate will prevent the execute method from running.

```ruby
#...
def validate
  if password != password_confirmation
    add_error(:password_confirmation, :doesnt_match, "Your passwords don't match")
  end
end
# ...

# That error would show up in the errors hash:
outcome.errors.symbolic # => {password_confirmation: :doesnt_match}
outcome.errors.message # => {password_confirmation: "Your passwords don't match"}
```

Alternatively you can also add these validations in the execute method:

```ruby
#...
def execute
  if password != password_confirmation
    add_error(:password_confirmation, :doesnt_match, "Your passwords don't match")
    return
  end
end
# ...

# That error would show up in the errors hash:
outcome.errors.symbolic # => {password_confirmation: :doesnt_match}
outcome.errors.message # => {password_confirmation: "Your passwords don't match"}
```

If you want to tie the validation messages into your I18n system, you'll need to [write a custom error message generator](https://github.com/cypriss/mutations/wiki/Custom-Error-Messages).

## FAQs

### Is this better than the 'Rails Way'?

Rails comes with an awesome default stack, and a lot of standard practices that folks use are very reasonable (eg, thin controllers, fat models).

That being said, there's a whole slew of patterns that are available to experienced developers. As your Rails app grows in size and complexity, my experience has been that some of these patterns can help your app immensely.

### How do I share code between mutations?

Write some modules that you include into multiple mutations.

### Can I subclass my mutations?

Yes, but I don't think it's a very good idea. Better to compose.

### Can I use this with Rails forms helpers?

Somewhat. Any form can submit to your server, and mutations will happily accept that input. However, if there are errors, there's no built-in way to bake the errors into the HTML with Rails form tag helpers. Right now this is really designed to support a JSON API.  You'd probably have to write an adapter of some kind.
