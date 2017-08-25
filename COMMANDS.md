# Tutspolls

## 01 02 - Bootstrapping the Project

make sure you add the following to the Gemfile

```ruby
gem 'spring'
```

```bash
$ rails new tutspolls
$ bundle install
$ bundle exec spring binstub --all
```

```bash
$ vi Gemfile
:g^#
:g::normal dd
```

## 2 1 Creating Polls

```bash
$ rails generate scaffold poll title
$ bin/rake db:migrate RAILS_ENV=development
```
Head over to following url: http://localhost:3000/polls

Go to _app/assets/stylesheets/application.css_ and the following:

Instead of just adding

```css
 *= require bootstrap
```
This worked for this application instead below _app/assets/stylesheets/application.css_:
```css
*= '_bootstrap'
```
Add this to _app/assets/javascript/application.js_
```javascript
//= require bootstrap-sprockets
//= require rails-ujs
//= require turbolinks
//= require_tree .
```

```bash
$ rake log:clear
```
Now we add the following to _app/models/post.rb_
```ruby
validates_presence_of :title
```
Now we can edit the current poll by remove the title and we get the following message:

```
1 error prohibited this poll from being saved:

Title can't be blank
```

Go to _/config/routes.rb_ and add the following:

```ruby
root 'polls#index'
```

Now go to http://localhost:3000/

Convert _app/views/layouts/application.html.erb_ to haml, there is html2haml gem but I used the following site: http://htmltohaml.com/

Copy current layout and paste the results.

Created a new folder: _app/views/application/&#95;nav.html.haml_

Make sure you go to the correct version of Bootstrap that matches the version that is provide within bootstrap-sass-3.3.7.gem

Go to [Bootstrap Navbar](https://getbootstrap.com/docs/3.3/components/#navbar)

## 02 02 Adding question

````bash
$ rails g scaffold question title kind poll:references
```
Now lets edit the _/config/routes.rb_ so move

```ruby
  resources :questions

  resources :polls
```
to

```ruby
root 'polls#index'
resources :polls do
    resources :questions
end
```

This allows us to have a route like:```/polls/1/questions```

Now we need to change the controller definition

In the controller, we define a before action that will call the set_poll method that will look for a poll by its poll_id within the Poll model; this will occur every time the question controller is requested.

When you request, ```/poll/1/questions```, the ```1``` is the poll_id

Now we look at _/app/views/questions/&#95;form.html.haml_, as you can see we have

```ruby
= form_for @question do |f|
```


but there isn't a route defined that only have ```/questions``` so  have modify the above form helper piece to include both

```ruby
= form_for [@poll, @question] do |f|
```
but we still have errors within _/app/views/questions/new.html.haml_

```ruby
= link_to 'Back', questions_path
```
because ```/questions_path``` doesn't exit but we can replace that path with ```@poll``` instance variable

to

```ruby
= link_to 'Back', @poll
```
In the middle of rendering the page, noticed that reference error with poll_id where nested question in poll was not being reference properly. Had to generate/run a new migration to fix the error

```bash
$ rails g migration AddPollIdToQuestions poll:references
$ rake db:migrate
```
Within _/app/views/questions/&#95;form.html.haml_, we do not want to show the poll text field

```ruby
= f.label :poll
= f.text_field :poll
```
but a hidden field like so

```ruby
= f.label :poll
= f.hidden_field :poll
```

But if you inspect the code in the browser, it doesn't have a value for the hidden_field

Remember the _/app/controller/questions_controller.rb_ has a new method that

```ruby
def new
  @question = @Question.new
end
```
but it should create a new question that relates to the current poll as it does in the following method

```ruby
def new
  @question = @poll.questions.build
end
```

In the _/app/models/polls.rb_, make sure there a relation

```ruby
class Poll < ApplicationRecord
  validates_presence_of :title

  has_many :questions  
end
```

After rendering  _app/views/questions/&#95;forms.html.haml_,
it populates the hidden_value a Poll object not a poll_id

It we look closely, we do not need Poll object on tis page at all because we have the  poll_id in. So we can remove the following session of code:

```ruby
= f.label :poll
= f.hidden_field :poll
```
