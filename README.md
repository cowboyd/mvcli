## MVCLI
[![Gem Version](https://badge.fury.io/rb/mvcli.png)](http://badge.fury.io/rb/mvcli)
[![Build Status](https://travis-ci.org/cowboyd/mvcli.png?branch=master)](https://travis-ci.org/cowboyd/mvcli)
[![Dependency Status](https://gemnasium.com/cowboyd/mvcli.png)](https://gemnasium.com/cowboyd/mvcli)

MVCLI is an first-class application framework for building command
line applications.

If you are familiar with other request-based MVC frameworks like Ruby
on Rails, then you will feel right at home with mvcli.

For an example of an application that uses this, see [rumm][1] 

### Getting Started

First, you will need to install the mvcli gem:

```
$ gem install mvcli
```

Now you can generate your mvcli application using the bundled `mvcli`
tool which is itself an application that uses the mvcli framework:

```
$ mvcli create application my-app
generating my-app in my-app/
  create my-app.gemspec
  create app.rb
  create app/routes.rb
  create app/controllers
  create app/controllers/.gitkeep
  create app/templates
  create app/templates/.gitkeep
  create bin
  create bin/my-app
  create lib
  create lib/my/app.rb
  create lib/my/app/version.rb
  create Gemfile
```


### Cores

All MVCLI applications are a collection of at least one core, where a
core is a bundle of controllers, routes, views, providers, etc... 

Any extension point in the system must be defined by a core, and can
re-reference the core in which it was defined. Optionally, a code can
be considered to be executing within a section. This serves as a
generic mechanism for associating behaviors by convention.

For example in the rumm tool, there is a provider of 'compute' values,
and if some code wants to use the compute service, it will declare
that fact with a `requires` statement:

```ruby
requires :compute
```

Let's assume that this value is dereferenced from within the
`ServersController` which executes in the `servers` section of the
`openstack` core. Actually dereferencing the `compute` value will
search for a provider object to realize it. Which providers will it
look for? Since we're in the `servers` section, it will first look for
a provider in the `providers/servers/compute_provider.rb` path of the
`openstack` core. If a provider cannot be found there, then it will
search in the `providers/compute_provider.rb` of the openstack
core. If it cannot be found there, it will search the main core
followed by any additional cores that are present in the system in the
order in which they were loaded.

core.lookup 'compute_provider'

[-] OpenStack
 |
 |- servers
 |- 
 






[1]: https://github.com/rackerlabs/rumm
