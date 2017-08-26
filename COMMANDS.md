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

Remember the _/app/controllers/questions_controller.rb_ has a new method that

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

Now that we look that the _app/views/questions/&#95;forms.html.haml_, we can see that entering a kind does not provide good user experience and we should convert it to radio buttons instead. Inside the _app/controllers/questions_controller.rb_, we going to add the following:

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

We need to go to _app/controllers/question_contoller.rb_ and make sure in new method that there is a possible_answer available to render for all new questions.

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

There was an issue when rendering the following code from the _app/controllers/question_comtroller.rb_

```ruby
def new
   @question = @poll.questions.build
   5.times {@question.possible_answers.build}
end
```

Inside the _app/views/questions/&#95;form.html.haml_, include the following code because it wasn't showing all the text_fields that map to the 5 possible answers created in the new method above

```ruby
=c.text_field :title,
         class:"form-control",
   placeholder:"Enter a possible answer here"
   if c.object.id.nil?
```
Base on following [StackOverflow post](https://stackoverflow.com/questions/14884704/how-to-get-rails-build-and-fields-for-to-create-only-a-new-record-and-not-includ)

This may be a new change in Rails 5 (5.1.3 current version for this application); need to review the [Ruby on Rais Guides](http://guides.rubyonrails.org/)

Currently, we have 5 possible answers but we may not use all of them when submitting  to the controller but it will send whatever is in the post payload. To fix this, we need to add the following code to the _app/models/questions.rb_ model.

```ruby
accepts_nested_attributes_for :possible_answers, reject_if: proc { |attributes| attributes['title'].blank? }
```
A proc allows us to have conditions that are extremely complex, the proc block will be evaluate for each set of attributes that is sent over to the controller. In our case, the any attributes contains a 'title' that is blank will be rejected

After clicking the 'save' button, everything looks good but it isn't.

Let's look at the log
```
Started POST "/polls/1/questions" for 127.0.0.1 at 2017-08-26 14:15:17 -0400
Processing by QuestionsController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"O4FpatbaXoGBh0b7avXrqWHEeu/itjs5LPn+QBn36BE+eCK0YfSejKmehGLlzrp10YxLYHRrC+a/TSpjjxuqPg==", "question"=>{"title"=>"What is language do you use the most?", "kind"=>"choice", "possible_answers_attributes"=>{"0"=>{"title"=>"Ruby"}, "1"=>{"title"=>"Python"}, "2"=>{"title"=>""}, "3"=>{"title"=>""}, "4"=>{"title"=>""}}}, "commit"=>"Save", "poll_id"=>"1"}
  [1m[36mPoll Load (1.0ms)[0m  [1m[34mSELECT  "polls".* FROM "polls" WHERE "polls"."id" = ? LIMIT ?[0m  [["id", 1], ["LIMIT", 1]]
> Unpermitted parameter: :possible_answers_attributes
  [1m[35m (0.0ms)[0m  [1m[36mbegin transaction[0m
  [1m[35mSQL (5.6ms)[0m  [1m[32mINSERT INTO "questions" ("title", "kind", "created_at", "updated_at", "poll_id") VALUES (?, ?, ?, ?, ?)[0m  [["title", "What is language do you use the most?"], ["kind", "choice"], ["created_at", "2017-08-26 18:15:18.114030"], ["updated_at", "2017-08-26 18:15:18.114030"], ["poll_id", 1]]
```
We tell the _app/controllers/questions_controller.rb_ accept the parameters from possible_answers but we must include hash of all the parameters that possible_answers can include as well.

```ruby
  def question_params
      params.require(:question).permit(:poll_id, :title, :kind, { possible_answers_attributes: [ :question_id, :title ] } )
  end
```
Now we look at the log
```
Started POST "/polls/1/questions" for 127.0.0.1 at 2017-08-26 14:45:21 -0400
Processing by QuestionsController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"BgytuE8E+WWqPPrCBPEz8jbrI9zN6i+P6srx/EkMTgXgw9wJf/f7m6AO41BmWl78vHZt1SZ1ZS4i3730hid/wA==", "question"=>{"title"=>"What is the best programming language do you use the most?", "kind"=>"choice", "possible_answers_attributes"=>{"0"=>{"title"=>"Ruby"}, "1"=>{"title"=>"Javascript"}, "2"=>{"title"=>""}, "3"=>{"title"=>""}, "4"=>{"title"=>""}}}, "commit"=>"Save", "poll_id"=>"1"}
  [1m[36mPoll Load (1.0ms)[0m  [1m[34mSELECT  "polls".* FROM "polls" WHERE "polls"."id" = ? LIMIT ?[0m  [["id", 1], ["LIMIT", 1]]
  [1m[35m (0.0ms)[0m  [1m[36mbegin transaction[0m
  [1m[35mSQL (2.0ms)[0m  [1m[32mINSERT INTO "questions" ("title", "kind", "created_at", "updated_at", "poll_id") VALUES (?, ?, ?, ?, ?)[0m  [["title", "What is the best programming language do you use the most?"], ["kind", "choice"], ["created_at", "2017-08-26 18:45:21.447446"], ["updated_at", "2017-08-26 18:45:21.447446"], ["poll_id", 1]]
  [1m[35mSQL (0.0ms)[0m  [1m[32mINSERT INTO "possible_answers" ("question_id", "title", "created_at", "updated_at") VALUES (?, ?, ?, ?)[0m  [["question_id", 23], ["title", "Ruby"], ["created_at", "2017-08-26 18:45:21.454466"], ["updated_at", "2017-08-26 18:45:21.454466"]]
>  [1m[35mSQL (0.0ms)[0m  [1m[32mINSERT INTO   "possible_answers" ("question_id", "title", "created_at",  "updated_at") VALUES (?, ?, ?, ?)[0m  [["question_id",  23], ["title", "Javascript"], ["created_at", "2017-08-26  18:45:21.458473"], ["updated_at", "2017-08-26 18:45:21.458473"]]
  [1m[35m (5.5ms)[0m  [1m[36mcommit transaction[0m
Redirected to http://localhost:3000/polls/1
Completed 302 Found in 36ms (ActiveRecord: 8.5ms)
```
As you can see, we have 3 SQL statement with one of them inserting into possible_answers to table. Now everything is working fine.

Next, we would like to show these possible answers on the management section.

Let's go to the _app/views/polls/show.html.haml_, add the following code to display the possible answers with questions in one place.

```ruby
%h2 Questions

%ul
  -@poll.questions.each  do |question|
    %li=question.title
    %ul
      -question.possible_answers.each do |possible_answer|
        %li=possible_answer.title
```
Before we move on we need to clean  up the database with all the null title records.

Refer to rake take: tutspolls:db_clean

Interesting CSV rake task from [stackoverflow](https://stackoverflow.com/questions/18859514/rails-rake-task-how-to-delete-records)

## 2.4 Replies and Answers

Now it time to go to the next level and allow the users to reply back to a poll.

Reply need to be referenced to a poll, question and possible answer. Refer back 1.3 Defining the Business Model.

```bash
$ rails g model reply poll:references
```
Remember that test are being generated with these rails generators but it is not justifiable to do our test just yet.

Now we create answer model, that references many other tables like particular reply, particular question, and in the case of multiply choice type question with reference the possible_answers plus if we have open answer question we nee to add a value.

```bash
$ rails g model answer reply:references question:references possible_answer:references value
$ rake db:migrate
```

Next its time to create the necessary forms to allow us to create relies and answers. First we'll craft a controller by hand; we could of done it with the scaffold generator but it would create extra files that we do not need right now. Create a file named: _app/controller/replies&#96;controller.rb_

Refer to class created above

Now we need to update _config/routes.rb_, it should now look this
```ruby
Rails.application.routes.draw do

  root 'polls#index'
  resources :polls do
      resources :questions
      resources :replies, only: [:new, :create]
  end
end
```
Now we need to review the generated routes

```bash
$ rake routes
```
Here is the list of available routes:
```bash
                        P r e f i x   V e r b       U R I   P a t t e r n                                                                     C o n t r o l l e r # A c t i o n  
                             r o o t   G E T         /                                                                                         p o l l s # i n d e x  
         p o l l _ q u e s t i o n s   G E T         / p o l l s / : p o l l _ i d / q u e s t i o n s ( . : f o r m a t )                     q u e s t i o n s # i n d e x  
                                       P O S T       / p o l l s / : p o l l _ i d / q u e s t i o n s ( . : f o r m a t )                     q u e s t i o n s # c r e a t e  
   n e w _ p o l l _ q u e s t i o n   G E T         / p o l l s / : p o l l _ i d / q u e s t i o n s / n e w ( . : f o r m a t )             q u e s t i o n s # n e w  
 e d i t _ p o l l _ q u e s t i o n   G E T         / p o l l s / : p o l l _ i d / q u e s t i o n s / : i d / e d i t ( . : f o r m a t )   q u e s t i o n s # e d i t  
           p o l l _ q u e s t i o n   G E T         / p o l l s / : p o l l _ i d / q u e s t i o n s / : i d ( . : f o r m a t )             q u e s t i o n s # s h o w  
                                       P A T C H     / p o l l s / : p o l l _ i d / q u e s t i o n s / : i d ( . : f o r m a t )             q u e s t i o n s # u p d a t e  
                                       P U T         / p o l l s / : p o l l _ i d / q u e s t i o n s / : i d ( . : f o r m a t )             q u e s t i o n s # u p d a t e  
                                       D E L E T E   / p o l l s / : p o l l _ i d / q u e s t i o n s / : i d ( . : f o r m a t )             q u e s t i o n s # d e s t r o y  
             p o l l _ r e p l i e s   P O S T       / p o l l s / : p o l l _ i d / r e p l i e s ( . : f o r m a t )                         r e p l i e s # c r e a t e  
         n e w _ p o l l _ r e p l y   G E T         / p o l l s / : p o l l _ i d / r e p l i e s / n e w ( . : f o r m a t )                 r e p l i e s # n e w  
                           p o l l s   G E T         / p o l l s ( . : f o r m a t )                                                           p o l l s # i n d e x  
                                       P O S T       / p o l l s ( . : f o r m a t )                                                           p o l l s # c r e a t e  
                     n e w _ p o l l   G E T         / p o l l s / n e w ( . : f o r m a t )                                                   p o l l s # n e w  
                   e d i t _ p o l l   G E T         / p o l l s / : i d / e d i t ( . : f o r m a t )                                         p o l l s # e d i t  
                             p o l l   G E T         / p o l l s / : i d ( . : f o r m a t )                                                   p o l l s # s h o w  
                                       P A T C H     / p o l l s / : i d ( . : f o r m a t )                                                   p o l l s # u p d a t e  
                                       P U T         / p o l l s / : i d ( . : f o r m a t )                                                   p o l l s # u p d a t e  
                                       D E L E T E   / p o l l s / : i d ( . : f o r m a t )                                                   p o l l s # d e s t r o y  
 ```
In the reply_params method, we have to make sure we place all the params that can be submitted to replies controller are included even they are need used in every request.  

```ruby
def reply_params
  params.require(:reply).permit({:poll_id answers_attributes: [ :value, :question_id, :reply_id, :possible_answer_id ] })
end
```
