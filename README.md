bauxite
=======

Bauxite is a façade over Selenium intended for non-developers

The idea behind this project was to create a tool that allows non-developers to write web tests in a human-readable language. Another major requirement is to be able to easily extend the test language to create functional abstractions over technical details.

Take a look at the following Ruby excerpt from http://code.google.com/p/selenium/wiki/RubyBindings:
```ruby
require "selenium-webdriver"

driver = Selenium::WebDriver.for :firefox
driver.navigate.to "http://google.com"

element = driver.find_element(:name, 'q')
element.send_keys "Hello WebDriver!"
element.submit

puts driver.title

driver.quit
```

While developers might find that code expressive enough, non-developers might be a bit shocked.

The equivallent Bauxite test is easier on the eyes:
```
open "http://google.com"
write name=q "Hello WebDriver!"
click gbqfb
```

Implementation
--------------

Bauxite is both a console program and a library. You can use the program to run Bauxite tests directly from a terminal, or you can embed the library in your own application.

The console program is called `bauxite.rb` and has a few command-line options (run `bauxite.rb -h` to see them all).

If you are looking to embed Bauxite in your application take a look a the code in `bauxite.rb`, that should give you a full example of how to create a Bauxite Context and execute some actions.

Basic usage
-----------

This is a brief intro into Bauxite, a hello world if you like.

First of all you'll need to install Firefox, Ruby, and a few gems:
 - selenium-webdriver
 - ruby-terminfo

Then clone the repo (I'll package this as a gem eventually).

Create a new file called `google.txt` and paste the following:
```
open "http://google.com"
write name=q "Hello WebDriver!"
click gbqfb
```

Finally, open a terminal window and run:
```
./bauxite.rb google.txt
```

Extending Bauxite
-----------------

Bauxite supports two types of extensions: functional extensions and coded plugins.

### Functional extensions

Functional extensions are composite constructs created using existing Bauxite actions to convey functional meaning. For example, imagine a login form:

```html
<!-- http://hostname/login.html -->
<form>
  <input id="username" name="username" type="text"     />
  <input id="password" name="password" type="password" />
  <input id="login" type="submit" value="Login"/>
</form>
```

The Bauxite code to login into this site would be:
```
open "http://hostname/login.html"
write username "jdoe"
write password "hello world!"
click login
```

If we were creating a suite of automated web tests for our *hostname* site, we'll probably need to login into the site several times. This would mean copy/pasting the four lines above into every test in our suite. 

Of course we can do better. We can split Bauxite tests into many files and include one test into another with the `load` action.

```
# my_test.txt (by the way, this is a comment)
load other_test_fragment.txt
...
```

Back to our login example, first we can package the login part of our tests into a separate Bauxite file:
```
# login.txt
open "http://hostname/login.html"
write username "jdoe"
write password "hello world!"
click login
```

Of course we would like to be able to login with different username/password combinations, so we can replace the literals in `login.txt` with variables:
```
# login.txt
open "http://hostname/login.html"
write username "${username}"
write password "${password}"
click login
```

Now, we would like to assert that both `username` and `password` variables are set before calling our test (just in case someone forgets). We can do this with `params`
```
# login.txt
params username password
open "http://hostname/login.html"
write username "${username}"
write password "${password}"
click login
```

In our main test we can load `login.txt` and specify the variables required using this code:
```
# main_test.txt
load login.txt username=jdoe "password=hello world!"

# additional actions go here
```

We could improve this even further by creating an `alias` to simplify the login process. To do this, lets create an new file called `alias.txt`:
```
# alias.txt
alias login load login.txt "username=${1}" "password=${2}"
```

Note that the `alias` action supports positional arguments.

Now we can change our main test to use our alias:
```
# main_test.txt
load alias.txt

login jdoe "hello world!"

# additional actions go here
```

That was a bit of work but the resuting test is purely functional (minus the load alias part, of course).

### Coded plugins

Coded plugins can be used to extend Bauxite actions, selectors and loggers. Coded plugins are Ruby files placed in the respective directory. See any of the current artifacts for a reference implementation.

