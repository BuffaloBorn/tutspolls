# Tutspolls

## 1.2 - Bootstrapping the Project

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

## 2.1 Creating Polls

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

## 2.2 Adding questions

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

Now that we look that the _app/views/questions/&#95;forms.html.haml_, we can see that entering a kind does not provide good user experience and we should convert it to radio buttons instead. Inside the _app/controller/questions_controller.rb_, we going to add the following:

```ruby
....
  before_action :set_kind_questions
....

private

  def set_kind_questions

  end
```
This will be called on every method for now but we can provide whitelist(include) of methods that should only be called on  

Here is a question you may ask yourself, in which ```poll``` is the ```question``` saved to?

Check out _log/development.log_,

```ruby
Started POST "/polls/1/questions" for 127.0.0.1 at 2017-08-25 15:28:49 -0400
Processing by QuestionsController#create as HTML
Parameters: {"utf8"=>"✓", "authenticity_token"=>"gxWBgAzyDCiEFRYwhE8Tg+NN8kvLkWMY1zDR2sIAV+GbN/wAdbRFlN8EswUNG1CkyGYeYbgw1mGQoG36DiclbA==", "question"=>{"title"=>"What is your name?", "kind"=>"open"}, "commit"=>"Save", "poll_id"=>"1", "id"=>"1"}
[1m[35mSQL (0.0ms)[0m  [1m[32mINSERT INTO "questions" ("created_at",  "kind","title","updated_at",) VALUES (?, ?, ?,?)[0m  [["created_at", "2017-08-25 19:28:40.944194"] ,["kind", "open"],["title","What is your name?"],["updated_at", "2017-08-25 19:28:40.944194"]]
```
As you can see, we have the all parameters passed into the controller as ```POST``` action but it is not inserted in the SQL statement when the SQL is constructed by ActiveRecord call.  

The issue lays within the _app/contoller/questions_controller.rb_, inside the create method.

```ruby
def create
    @question = Question.new(question_params)
    ...
end
```
needs to use the following syntax as te new method
```ruby
def create
      @question = @poll.questions.build(question_params)
    ...
end
```
Make sure pay attention to ```question_params``` method is defined in the private section

This is a rails way of restricting a particular dataset that is coming from the outside.

## 2.3 Adding Possible Answers

In this case, we do not need to generate a scaffold because the way to create answer is though a question form

```bash
$ rails g model possible_answers
$ rake db:migrate
```
Need to modify the _app/models/question.rb_ to inform questions model that it has many possible answers

```ruby
  has_many :possile_answers
```

Now we look at _app/views/questions/&#95;form.html.haml_ and add the following

```ruby
-f.fields_for :possible_answers do |c|
  =c.text  
```
This allow us to define fields for associated models

So if we render this page, it will not display anything because there isn't any possible answers available to this question.

We need to go to _app/controller/question_contoller.rb_ and make sure in new method that there is a possible_answer available to render for all new questions.

Below shows how the new method should look

```ruby
def new
  @question = @poll.questions.build
  @question.possible_answers.build
end
```
Keep in mind that there only a single available possible_answer
provided

Note: When working with haml or any view rendering framework like plain old rails syntax: remember to review output syntax like ```=```, ```<%= %>``` vs ```-```, ```<%%>```. I spent a couple of hours trying to figure out if the model layer was not configured properly but it was actually a view syntax error that was not catch by rails.   
