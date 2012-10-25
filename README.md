# Mutations

Mutations validate and sanitize input, then pass it to your function.  You can use this to write safe, re-usable, maintainable code for Ruby and Rails apps.

## Installation

    gem install mutations
    
Or add it to your Gemfile:

    gem 'mutations'

## Example

```# Define a command that signs up a user.
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
    render json: outcome.errors.symbolic
  end
end
```

Some things to note about the example:

* We don't need attr_accessible or strong_attributes to protect against mass assignment attacks
* We're guaranteed that within execute, the inputs will be the correct data types, even if they needed some coercion (all strings are stripped by default, and strings like "1" / "0" are converted to true/false for newsletter_subscribe) 
* We don't need ActiveRecord/ActiveModel validations
* We don't need Callbacks on our models -- everything is in the execute method (helper methods are also encouraged).
* We don't use accepts_nested_attributes_for, even though multiple AR models are created.
* This code is completely re-usable in other contexts (need an API?)
* The inputs to this 'function' are documented by default -- the bare minimum to use it (name and email) are documented, as are 'extras' (newsletter_subscribe).

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

That being said, you can easily use the input validation/specification capabilities for things that don't mutate your database.

## How do I call mutations?

You have two choices. Given a mutation UserSignup, you can do this:

    outcome = UserSignup.run(params)
    if outcome.success?
      user = outcome.result
    else
      render outcome.errors
    end

Or, you can do this:

    user = UserSignup.run!(params) # returns the result of execute, or raises Mutations::ValidationException

## What can I pass to mutations?

Mutations only accept hashes as arguments to #run and #run!

That being said, you can pass multiple hashes to run, and they are merged together. Later hashes take precedence. This give you safety in situations where you want to pass unsafe user inputs and safe server inputs into a single mutation. For instance:

    # A user comments on an article
    class CreateComment < Mutations::Command
      requried do
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

Here, we pass two hashes to CreateComment. Even if the params[:comment] hash has a user or article field, they're overwritten by the second hash. (Also note: even if they weren't, they couldn't be of the correct data type in this particular case.)

## How do I define mutations?

1. Subclass Mutations::Command

    class YourMutation < Mutatons::Command
      ...
    end

2. Define your required inputs and their validations:

    required do
      string :name, max_length: 10
      string :state, in: %w(AL AK AR ... WY)
      integer :age
      boolean :is_special, default: true
      model :account
    end

3. Define your optional inputs and their validations:

    optional do
      array :tags, class: String
      hash :prefs do
        boolean :smoking
        boolean :view
      end
    end

4. Define your execute method. It can return a value:

    def execute
      record = do_thing(...)
      ...
      record
    end

## How do I write an execute method?

Your execute method has access to the inputs passed into it:

    self.inputs # white-listed hash of all inputs passed to run.  Hash has indifferent access.
    
If you define an input called _email_, then you'll have these three methods:

    self.email           # Email value passed in
    self.email=(val)     # You can set the email value in execute. Rare, but useful at times.
    self.email_present?  # Was an email value passed in? Useful for optional inputs.

You can do extra validation inside of execute:

    if email =~ /aol.com/
      add_error(:email, :old_school, "Wow, you still use AOL?")
      return
    end

You can return a value as the result of the command:

    def execute
      # ...
      "WIN!"
    end
    
    # Get result:
    outcome = YourMutuation.run(...)
    outcome.result # => "WIN!"

## What about validation errors?

- your 

## FAQs

### Is this better than the 'Rails Way'?

Rails comes with an awesome default stack, and a lot of standard practices that folks use are very reasonable (eg, thin controllers, fat models).

That being said, there's a whole slew of patterns that are available to experienced developers. As your Rails app grows in size and complexity, my experience has been that some of these patterns can help your app immensely.

### How do I share code between mutations?

### Can I subclass my mutations?

### What's left to do?







