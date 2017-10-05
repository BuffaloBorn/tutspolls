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

A reply needs to be referenced to a poll, question and possible answer. Refer back 1.3 Defining the Business Model.

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

With the _app/controller/replies&#96;controller.rb_, we need to have a _new_ and _create_ method.

In the _new_, we need to make sure that we have reference to the poll object and that can be established by finding the poll via the _poll&#96;id_ from the parameters passed to this controller and the we can  start building a reply object in memory.

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

```

Above we've just double checking if we have the two new routes that we can reference:

new&#96;poll&#96;reply and poll&#96;replies

In our _create_ method, we need to establish a new _@reply_ instance variable that is created from the _@poll.replies.build_ operation from there we can attempt to save our newly constructed _@reply_ instance variable that is constructed with the _:reply_ parameter and then redirected to the actual poll that we've found earlier plus we can populate the _notice_ buffer or we'll render a new reply page.

Before the _create_ method creates a poll, we need to found a poll with the poll_id passed into the controller.

We need to create _reply_params_ method, that will be ```private```, we have to make sure we place all the params that can be submitted to the replies controller in a single location so that we can centralize this reference without the controller; we need to included all possible params even if they are not used in any method sections.  

```ruby
def reply_params
  params.require(:reply).permit(:poll_id, {answers_attributes: [ :value, :question_id, :reply_id, :possible_answer_id ] })
end
```

Recall, that   ```answers_attributes: [ :value, :question_id, :reply_id, :possible_answer_id ] ``` is a hash that passes the answers parameters that is nested with the controller request.

Now we need to modify _app/models/reply.rb_, make sure it has access to many answers and it can access to nested attributes from answers as well.

```ruby
class Reply < ApplicationRecord
  belongs_to :poll
  has_many :answers

  accepts_nested_attributes_for :answers
end
```

In addition, we need to go to _app/models/question.rb_, make sure we tell questions that it may have many answers by adding this below:

```ruby
  has_many :answers
```

By adding this to _app/models/question.rb_ it useful later to gather useful statistics. It seems that this completes all the changes that we need for the controllers and models level.

It time to modify the view to access the new answers features.

Create _app/views/replies/new.html.haml_, review the code that was added inside

Next we need to modify _app/views/polls/index.html.haml_ to include the following link:

```ruby
= link_to 'Answer', new_poll_reply_path(poll), class: "btn btn-default"
```

this will allow his access the replies_controller&#39;s new method. If we click on the Answer button, it will generate the following error:

```ruby
NoMethodError at /polls/1/replies/new
undefined method `replies' for #<Poll:0x0000000e9a9c88>
```

The above error was fixed after reviewing the controller and model classes adding the needed references.  

We need to go to the _app/models/poll.rb_ and add code:

```ruby
has_many :replies
```
Because the ```@reply``` object was not saving and it was falling into the else block in the create method. To debug this, added ```raise &#39;something&#39;```  to that else block and run the following code at the console.

```bash
@reply.errors.full_messages
=> ["Answers possible answer must exist"]
```
And discovered the following message above. It lead to google search to [stackoverflow](https://stackoverflow.com/questions/40276008/form-with-nested-attributes-not-saving-rails-5)

Rails 5 association belongs to failed validate your [associated] id, so your entry is getting rollback.

This informed me to check out the _app/models/answer.rb_ and add ```optional: true``` to ```belongs_to :possible_answer``` so it looks like ```belongs_to :possible_answer, optional: true```

This now gives us the results we are looking for.

Now we can focus on the view, start looping the answers even though we do not have any answers but we need to go in the replies controller and create answers base on each questions in a given poll.

The rest of the this section will be base on the ```view``` portion of the MVC model

```ruby
=c.label :value, c.object.questio.title
=c.text_field :value, class:"form-control"
```
to make more dynamic for different kinds of questions

```ruby
=render c.object.question.kind, c: c
```
Remember that the ```c: c``` variable being passed to each partial that is rendered by section

Let go to rails console to make sure that there is not a nil value for kind. Below are steps way to resolve any records that may contain a nil for kind

```bash
$ rails console
```
```ruby
> Question.all
> Question.last
> Question.last.update :kind "choice"
```
At this point we do have any makup for the  _app/views/replies/_choice.html.haml_ partial

## 2.5 Display Reply Data

Let review what we have done so far.

We listing all the polls and each poll have a question with it perspective possible answers. Plus know how to answer a particular type of poll.

Now we going to the details of a poll and list all answers that have been all ready provide for a poll. This is the point where we start to gather intelligence about a panel.

Go _app/views/polls/show.html.haml_, append the following above the established links

```ruby
-@poll.replies.each do |reply|
  .col-md-6
    .panel.panel-default
      .panel-heading.text-right
        =time_ago_in_words reply.created_at
      .panel-body
        %dl
          -reply.answers.each do |answer|
            %dt=answer.question.title
            %dd
              =answer.value.present? ? answer.value : answer.possible_answer.title
```

As we review the additional narkup add in this section, we see that we have created the following stucture:

```haml
.col-md-6 -> 6 column division
  .panel.panel-default -> panel section
    .panel-heading.text-right -> header that is aligned to the right
          =time_ago_in_words reply.created_at -> simplely display time the poll was tooken and created
        .panel-body -> a body for that panel
          %dl -> definition list
            -reply.answers.each do |answer|
              %dt=answer.question.title
              %dd
                =answer.value.present? ? answer.value : answer.possible_answer.title
```

The idea being that the term-to-be-defined is held in the <dt> element, and the definition of that term is given in the <dd>. We can see that the first question displays the value that we stored for the answer but for the second question we are showing the possible answer because it value we can choose from. The question is multiple choose not free form answer. This do to the fact that  ```=answer.value.present? ? answer.value : answer.possible_answer.title``` checks if we are displaying a value or a possible_answer&#39;s title.


One thing that we can do to improve the layout is to move the button in above the new Replies header.

We also going to add a tab navigation by using bootstrap standard layout from [bootstrap js](https://getbootstrap.com/docs/3.3/javascript/). Here we will see many components that relay on javascript but we only care for is [bootstrap tab](https://getbootstrap.com/docs/3.3/javascript/#tabs

Here we can see that tabs that can have dropdowns or not. In our case, we are just have three tabs one for questions, one for replies and the last one for statistics. So are do not want to rely on to much javascript so we are going to use ```data-attributes```. We are listing all the tabs and provide a section of ```div```s that will have our previous content.

```html
<div>
  <!-- Nav tabs -->
  <ul class="nav nav-tabs" role="tablist">
    <li role="presentation" class="active"><a href="#home" aria-controls="home" role="tab" data-toggle="tab">Home</a></li>
    <li role="presentation"><a href="#profile" aria-controls="profile" role="tab" data-toggle="tab">Profile</a></li>
    <li role="presentation"><a href="#messages" aria-controls="messages" role="tab" data-toggle="tab">Messages</a></li>
    <li role="presentation"><a href="#settings" aria-controls="settings" role="tab" data-toggle="tab">Settings</a></li>
  </ul>

  <!-- Tab panes -->
  <div class="tab-content">
    <div role="tabpanel" class="tab-pane active" id="home">...</div>
    <div role="tabpanel" class="tab-pane" id="profile">...</div>
    <div role="tabpanel" class="tab-pane" id="messages">...</div>
    <div role="tabpanel" class="tab-pane" id="settings">...</div>
  </div>

</div>
```


After converting the above bootstrap tab code to haml by using the aboe website and making the correct modifitions to fit what we are looking for. To make the tabs work properly we need to add the below bootstrap js reference in ```app/views/layouts/application.html.erb```

```javascript
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
```

## 3.1 Polls Taken Over Time_ Gathering Data

Up until now, we have provided users the means to defined a set polls with questions and possible answers thay can take.

We also given the user a chance to take to reply to the poll answer with each question that is apart the poll in which is related to a reply object.

Now we will focus on the statistics aspect of the data collected of each poll. We will provide a meanful visalize of that data.

We are going to take a different approuch and create our poll serializer.  THis will be place in a class that will have two methods; one for each question that was developed earlier lessons.

First we are going to the test folder and create an ```unit``` folder. The ```unit``` folder is special in ruby on rails because it contaims deciated task in the rake file.

Our class will be named: poll_serializer so we will create a sub-folder named: poll_serializer as well.

Inside the ```poll_serializer``` folder, we will create series of test classes on for each kind of intelligence.

The first one on ```count_per_month_test.rb``` and this one will on focus first question: "How many polls was taken per month?"

In our ```count_per_month_test.rb``` class, we need to add

```
require "test_helper"
```

We are not going to inherit from any other rails helper class because we do not have to.

```
include FactoryGirl::Syntax::Methods
```

This will allow us to inject factories into our test. Next we will insert a series of test and will focus on one at a time.


```
attr_reader :poll

  def setup
    @poll = create :full_poll, replies_count: 5, questions_count: 5
    @stats = PollSerializer.count_per_month(poll)
  end

  def test_retrieves_data_in_the_form_of_an_array
    assert_includes @stats.keys, :data
  end

  def test_polls_per_month_have_numbers
    assert_kind_of Numeric, @stats[:data].first
  end

  def test_polls_per_month_have_x_axis
    assert_equal "Polls per month", @stats.fetch(:x_axis).fetch(:legend)
  end

  def test_polls_per_month_have_x_axis_series
    assert_kind_of Array, @stats.fetch(:x_axis).fetch(:series)
  end

  def test_polls_per_month_have_x_axis_series_in_proper_format
    assert_includes @stats.fetch(:x_axis).fetch(:series).first, Time.now.strftime("%b %Y")
  end

  def test_polls_per_month_have_y_axis
    assert_equal "No. polls", @stats.fetch(:y_axis).fetch(:legend)
  end

  def test_polls_per_month_have_y_axis_max_range
    assert_equal 0, @stats.fetch(:y_axis).fetch(:scale)[0]
  end

  def test_polls_per_month_have_y_axis_max_range
    assert_equal 6, @stats.fetch(:y_axis).fetch(:scale)[1]
  end

```

Here is an overview of what each of the test does:

  * setup -   creates two instance variables: a poll and a PollSerializer . We are assuming that these classes exist already
    1. for the @poll variable we are using full_poll factory that will create a set of questions and a set of replies that is associated
    2. With the PollSerializer class there is a count_per_month method that is defined and accepts a poll as a parameter

  * test_retrieves_data_in_the_form_of_an_array -we want to have a data element in the array
  * test_polls_per_month_have_numbers - we want make sure that each element in the array is Numeric
  * test_polls_per_month_have_x_axis - we want to make sure there is a legend for the x_axis
  * test_polls_per_month_have_x_axis_series - we want to make sure there is an array that contain the entire series
  * test_polls_per_month_have_x_axis_series_in_proper_format - we want make the is contains a timestamp that provides meanful visalization
  * test_polls_per_month_have_y_axis - make sre we have legend for the y axis
  * test_polls_per_month_have_y_axis_max_range - minumim value this provides meanful visalization
  * test_polls_per_month_have_y_axis_max_range - maxium value thus provides meanful visalization
      If we a have max of 5 in given month, then we should have 1 over that value.

  We are going to skip all test beside the first two. 
