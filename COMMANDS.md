# timetracker

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
:g:^#
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
@import "bootstrap-sprockets";
@import "bootstrap";
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
