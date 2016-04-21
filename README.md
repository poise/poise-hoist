# Poise-Hoist

[![Build Status](https://img.shields.io/travis/poise/poise-hoist.svg)](https://travis-ci.org/poise/poise-hoist)
[![Gem Version](https://img.shields.io/gem/v/poise-hoist.svg)](https://rubygems.org/gems/poise-hoist)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise.svg)](https://supermarket.chef.io/cookbooks/poise)
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

default['staging']['myapp']['debug_mode'] = true
default['prod']['myapp']['debug_mode'] = false
```

## Sponsors

Development sponsored by [Bloomberg](http://www.bloomberg.com/company/technology/).

The Poise test server infrastructure is generously sponsored by [Rackspace](https://rackspace.com/). Thanks Rackspace!

## License

Copyright 2016, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
