bauxite
=======

Bauxite is a façade over Selenium intended for non-developers

The idea behind this project was to create a tool that allows non-developers to write web tests in a human-readable language. Another major requirement is to be able to easily extend the test language to create functional abstractions over technical details.

Take a look at the following Ruby excerpt from http://code.google.com/p/selenium/wiki/RubyBindings:

    require "selenium-webdriver"
    
    driver = Selenium::WebDriver.for :firefox
    driver.navigate.to "http://google.com"
    
    element = driver.find_element(:name, 'q')
    element.send_keys "Hello WebDriver!"
    element.submit
    
    puts driver.title
    
    driver.quit

While developers might find that code expressive enough, non-developers might be a bit shocked.

The equivalent Bauxite test is easier on the eyes:

    open "http://google.com"
    write "name=q" "Hello WebDriver!"
    click "gbqfb"


Installation
------------

In a nutshell:

    gem install bauxite


If you don't have Ruby 2.x yet, check the [Installing Ruby](#installing-ruby) section below.

Remember you should probably install [Firefox](http://www.mozilla.org) (unless you want to use other browsers or Selenium server by specifying the `-p` switch to the `bauxite` executable).

Hello World
-----------

Paste the following text into `hello.bxt`:

    open "http://www.gnu.org/fun/jokes/helloworld.html"

Launch a terminal/command prompt and type:

    bauxite hello.bxt

Command-line Interface
----------------------

The `bauxite` command-line program supports several configuration options.

Refer to the [RDoc documentation](http://pzavolinsky.github.io/bauxite/Bauxite/Application.html) for more details.


The Bauxite Language
--------------------

The Bauxite language is composed of two elements `Actions` and `Selectors`: Actions are testing operations such as "open this page", "click this button", "write this text into that textbox", etc. Selectors are ways of locating interesting elements of a page such as a button, a textbox, a label, etc.

A typical Bauxite test is a plain text file that contains a series of Actions (one per line). Depending on the Action, a few action arguments might need to be specified as well. For example in:

    open "http://google.com"
    write "name=q" "Hello WebDriver!"
    click "gbqfb"

`open`, `write` and `click` are Actions:
- `open` takes a single URL argument (`"http://google.com"`) and opens that URL in the browser.
- `write` takes two arguments, a Selector (`name=q`, more on this in a bit) and a text (`"Hello WebDriver!"`), and writes the text into the element specified by the Selector.
- `click` takes a single Selector argument (`gbqfb`) and clicks the element specified by the Selector.

In general, Action arguments can be surrounded by optional double quote characters (`"`). If an argument contains a space character, the quotes are mandatory (this is the case for the second argument to `write` in the example above).

Some Actions operate on page elements (e.g. `write`, `click`, etc.). In order to locate these elements, Bauxite uses Selectors.

The trivial Selector is just a text that matches the last portion of the `id` attribute of the target element. 

For example, in this HTML fragment:

    <input type="submit" id="gbqfb" value="Search" />

If we want to click the "Search" button we can do the following:

    click "gbqfb"

Bauxite supports several other Selectors such as `name=` in the example above. The `name` Selector finds elements whose `name` attribute matches the text following the `=` sign.

For example, in this HTML fragment:

    <input type="text" name="q" />

If we want to type the text "Hello WebDriver!" in the textbox we can do the following:

    write "name=q" "Hello WebDriver!"

This section presented a  brief introduction into the basic Bauxite concepts. For more details and a list of every Action and Selector available, refer to the RDoc generated documentation in:

 - [Available Actions](http://pzavolinsky.github.io/bauxite/Bauxite/Action.html#Action+Methods)
 - [Available Bauxite Selectors](http://pzavolinsky.github.io/bauxite/Bauxite/Selector.html#Selector+Methods)
 - [Selenium Standard Selectors](http://pzavolinsky.github.io/bauxite/Bauxite/Selector.html#class-Bauxite::Selector-label-Standard+Selenium+Selectors)
 - [Bauxite Variables](http://pzavolinsky.github.io/bauxite/Bauxite/Context.html#class-Bauxite::Context-label-Context+variables)
 - [Creating new Actions](http://pzavolinsky.github.io/bauxite/Bauxite/Action.html)
 - [Creating new Selectors](http://pzavolinsky.github.io/bauxite/Bauxite/Selector.html)

Installing Ruby
---------------

I won't cover all the details of installing Ruby on your system (Google knows best), but the following should probably work.

In GNU/Linux, you can install [RVM](http://rvm.io/), then Ruby:

    curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
    rvm install ruby-2.1.0

In Windows, you can install Ruby 2.x with [RubyInstaller](http://rubyinstaller.org/downloads/). After everything is installed, launch the `Start Command Prompt with Ruby` option in your start menu.

Regadless of your OS, you should be able to install Bauxite with:

    gem install bauxite

Implementation
--------------

Bauxite is both a command-line program and a library. You can use the program to run Bauxite tests directly from a terminal, or you can embed the library in your own application.

The command-line program is called `bauxite` and has several command-line options, refer to the [RDoc documentation](http://pzavolinsky.github.io/bauxite/Bauxite/Application.html) for more details.

If you are looking to embed Bauxite in your application take a look a the code in `lib/bauxite/application.rb`, that should give you a full example of how to create a Bauxite Context and execute some actions.

Extending Bauxite
-----------------

Bauxite supports two types of extensions: functional extensions and coded plugins.

### Functional extensions

Functional extensions are composite constructs created using existing Bauxite actions to convey functional meaning. For example, imagine a login form:

    <!-- http://hostname/login.html -->
    <form>
      <input id="username" name="username" type="text"     />
      <input id="password" name="password" type="password" />
      <input id="login" type="submit" value="Login"/>
    </form>

The Bauxite code to login into this site would be:

    open "http://hostname/login.html"
    write "username" "jdoe"
    write "password" "hello world!"
    click "login"

If we were creating a suite of automated web tests for our *hostname* site, we'll probably need to login into the site several times. This would mean copy/pasting the four lines above into every test in our suite. 

Of course we can do better. We can split Bauxite tests into many files and include one test into another with the `load` action.

    # my_test.bxt (by the way, this is a comment)
    load other_test_fragment.bxt
    ...

Back to our login example, first we can package the login part of our tests into a separate Bauxite file:

    # login.bxt
    open "http://hostname/login.html"
    write "username" "jdoe"
    write "password" "hello world!"
    click "login"

Of course we would like to be able to login with different username/password combinations, so we can replace the literals in `login.bxt` with variables:

    # login.bxt
    open "http://hostname/login.html"
    write "username" "${username}"
    write "password" "${password}"
    click "login"

Now, we would like to assert that both `username` and `password` variables are set before calling our test (just in case someone forgets). We can do this with `params`

    # login.bxt
    params username password
    open "http://hostname/login.html"
    write "username" "${username}"
    write "password" "${password}"
    click "login"

In our main test we can load `login.bxt` and specify the variables required using this code:
    
    # main_test.bxt
    load "login.bxt" "username=jdoe" "password=hello world!"
    
    # additional actions go here

We could improve this even further by creating an `alias` to simplify the login process. To do this, lets create an new file called `alias.bxt`:

    # alias.bxt
    alias "login" "load" "login.bxt" "username=${1}" "password=${2}"

Note that the `alias` action supports positional arguments.

Now we can change our main test to use our alias:

    # main_test.bxt
    load "alias.bxt"
    
    login "jdoe" "hello world!"
    
    # additional actions go here

That was a bit of work but the resulting test is purely functional (minus the load alias part, of course).

### Coded plugins

Coded plugins are Ruby files that extend the Bauxite language by providing additional language elements. Coded plugins can be used to create Bauxite actions, selectors and loggers.

For example lets assume that throughout a web application input elements were identified using a custom HTML attribute instead of `id`. For example:

    <form>
      <input custom-attr="username" type="text"     />
      <input custom-attr="password" type="password" />
      <input custom-attr="login"    type="submit" value="Login"/>
    </form>

Using standard Bauxite language we could select these elements using:

    # === my_test.bxt === #
    write "attr=custom-attr:username" "jdoe"
    write "attr=custom-attr:password" "hello world!"
    click "attr=custom-attr:login"

But we can improve the overall readability of our test by using a coded plugin:

    # === plugins/custom_selector.rb === #
    class Bauxite::Selector
        def custom(value)
            attr "custom-attr:#{value}"
        end
    end

Now we can change our test to look like this:

    # === my_test.bxt === #
    write "custom=username" "jdoe"
    write "custom=password" "hello world!"
    click "custom=login"

Finally, to execute Bauxite loading our plugin we can type:

    bauxite -e plugins my_test.bxt

Jenkins Integration
-------------------

If you want to run Bauxite tests in your [Jenkins CI](http://jenkins-ci.org/) server you must install `xvfb` and `selenium-server-standalone`. Googling for `selenium headless jenkins <your distro>` is a great start. Assuming you installed Ruby and Bauxite for the `jenkins` user (see the instructions above), you can create an execute shell build task with the following text:

    #!/bin/bash
    source ~/.rvm/scripts/rvm
    bauxite -l echo -u http://localhost:4444/wd/hub          \
            -t 60 -o 240 --csv-summary "$WORKSPACE/test.csv" \
            "$WORKSPACE/test/suite.bxt"

Assuming you have Selenium Server running on localhost and your workspace (e.g. GIT repo) contains a folder named `test` with a file named `suite.bxt` the configuration above should work like a charm.

`suite.bxt` could be something like:

    # === suite.bxt === #
    test login.bxt
    test register.bxt
    test browse_around.bxt
    test purchase_something.bxt
    # more tests here...

Note the `--csv-summary` option in the configuration above. That option generates a single-line CSV file ideal to feed into the `Plot` Jenkins plugin. I won't go into the details of configuring the Plot plugin, but instead here is a fragment of a possible Jenkins `config.xml` plotting the Bauxite test results:

    <publishers>
      ...
      <hudson.plugins.plot.PlotPublisher plugin="plot@1.5">
        <plots>
          <hudson.plugins.plot.Plot>
            <title>Number of tests</title>
            <yaxis>Number of tests</yaxis>
            <series>
              <hudson.plugins.plot.CSVSeries>
                <file>test.csv</file>
                <label></label>
                <fileType>csv</fileType>
                <strExclusionSet>
                  <string>OK</string>
                  <string>Failed</string>
                  <string>Total</string>
                </strExclusionSet>
                <inclusionFlag>INCLUDE_BY_STRING</inclusionFlag>
                <exclusionValues>Total,OK,Failed</exclusionValues>
                <url></url>
                <displayTableFlag>false</displayTableFlag>
              </hudson.plugins.plot.CSVSeries>
            </series>
            <group>Test</group>
            <numBuilds>100</numBuilds>
            <csvFileName>1620406039.csv</csvFileName>
            <csvLastModification>0</csvLastModification>
            <style>line</style>
            <useDescr>false</useDescr>
          </hudson.plugins.plot.Plot>
          <hudson.plugins.plot.Plot>
            <title>Test Execution Time</title>
            <yaxis>Test time (s)</yaxis>
            <series>
              <hudson.plugins.plot.CSVSeries>
                <file>test.csv</file>
                <label></label>
                <fileType>csv</fileType>
                <strExclusionSet>
                  <string>Time</string>
                </strExclusionSet>
                <inclusionFlag>INCLUDE_BY_STRING</inclusionFlag>
                <exclusionValues>Time</exclusionValues>
                <url></url>
                <displayTableFlag>false</displayTableFlag>
              </hudson.plugins.plot.CSVSeries>
            </series>
            <group>Test</group>
            <numBuilds>100</numBuilds>
            <csvFileName>336296054.csv</csvFileName>
            <csvLastModification>0</csvLastModification>
            <style>line</style>
            <useDescr>false</useDescr>
          </hudson.plugins.plot.Plot>
        </plots>
      </hudson.plugins.plot.PlotPublisher>
      ...
    </publishers>

