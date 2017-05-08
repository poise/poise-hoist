# Poise-Hoist

[![Build Status](https://img.shields.io/travis/poise/poise-hoist.svg)](https://travis-ci.org/poise/poise-hoist)
[![Gem Version](https://img.shields.io/gem/v/poise-hoist.svg)](https://rubygems.org/gems/poise-hoist)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise-hoist.svg)](https://supermarket.chef.io/cookbooks/poise-hoist)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-hoist.svg)](https://codecov.io/github/poise/poise-hoist)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-hoist.svg)](https://gemnasium.com/poise/poise-hoist)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A cookbook to help automate "attribute hoisting" when using Chef with Policyfiles.

Attribute hoisting is a way to store per-policy-group attributes in a policy to
allow similar settings to environment-level attributes in a pre-Policyfile
workflow. Just put the desired attributes under a top-level key matching the
name of the policy group and add `poise-hoist` either to your run list or to
your cookbook dependencies.

## Quick Start

In your Policyfile:

```ruby
name 'myapp'

run_list 'poise-hoist', 'myapp'

# Default value for all groups.
default['myapp']['debug_mode'] = true

# Per-group values, will be hoisted on top of the default above.
default['staging']['myapp']['debug_mode'] = 'extra_verbose'
default['prod']['myapp']['debug_mode'] = false
```

and then in your recipe code:

```ruby
some_resource 'name' do
  debug_mode node['myapp']['debug_mode']
end
```

This automatically hoists up policy attributes set under a top-level key
matching the name of the policy group of the current node.

## Requirements

Chef 12.2 or newer is required.

## Use With Test Kitchen

When testing policies with the `policyfile_zero` provisioner plugin, the policy
group will always be `local`.

```ruby
default['local']['myapp']['debug_mode'] = true
```

## Environment Shim

For older cookbooks still expecting to use `node.chef_environment`, by default
that method will be patched to return the policy group label instead. This can
be disabled by setting `node['poise-hoist']['hoist_chef_environment'] = false`.

## Data Bag Attributes

To pull in data from a data bag, set `default['poise-hoist']['data_bag'] = 'the name of the data bag'`
in your Policyfile. It will look for an item in the specified data bag using the
name of the node and then the name of policy group. You can use this in
combination with the normal group-level hoisting to have a different data bag
name for some policy groups.

This can be useful in combination with attributes from the Policyfile to provide
immediate overrides outside of the "compile and push" cycle of the policy system.

## Sponsors

Development sponsored by [Bloomberg](http://www.bloomberg.com/company/technology/).

The Poise test server infrastructure is generously sponsored by [Rackspace](https://rackspace.com/). Thanks Rackspace!

## License

Copyright 2016-2017, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
