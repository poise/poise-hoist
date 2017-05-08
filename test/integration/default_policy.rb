#
# Copyright 2016-2017, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name 'default'
run_list 'poise-profiler', 'poise-hoist_test'

default['other']['hoist_test']['one'] = 100
default['local']['hoist_test']['one'] = 11
override['hoist_test']['two'] = 22
override['other']['hoist_test']['two'] = 220
override['local']['hoist_test']['two'] = 222
