---
title: Using drip with JRuby
author: Robert Jackson
date: 2013-01-21
published: true
tags: jruby ruby
---
[Drip](https://github.com/flatland/drip) is an awesome command line tool that can be used to dramatically lower perceived JVM startup time.  It does this by preloading an entirely new JVM process\instance and allowing you to simply use the preloaded environment.  This has extraordinary results with jruby.  

READMORE

We reduced time to run `rake environment` from 13 seconds to a mere 3.5 seconds.  This is actually at or near MRI 1.9.3p327 (with falcon patch) speeds!

Adding a few addition [jruby options](https://github.com/jruby/jruby/wiki/Improving-startup-time) will reduce startup time even further (down to 1.69 seconds).

#Install Drip
Install drip if you haven't already (see https://github.com/flatland/drip)

```bash
brew update && brew install drip
```

#Environment Setup
jruby uses the JAVACMD environment variable (if present) as it's executable (usually `which java`). 
drip uses the DRIP\_INIT\_CLASS environment variable to determine the main class to load.  jruby has a native java class already setup for this purpose: [orb.jruby.main.DripMain](https://github.com/jruby/jruby/blob/master/src/org/jruby/main/DripMain.java).

```bash
export JAVACMD=`which drip`
export DRIP_INIT_CLASS=org.jruby.main.DripMain
```

#Project Setup
Put any project specific initialization code (ruby code) in PROJECT_ROOT/dripmain.rb. This file is automatically called by the special org.jruby.main.DripMain class when intializing the standby JVM process.

```bash
# rails project:
require_relative 'config/application'

# non-rails bundler controlled project
require 'bundler/setup'
Bundler.require
```

#rvm integration
If you would like to use drip automatically whenever you switch to jruby with rvm you will need to add a new hook file at $rvm\_path/hooks/after\_use\_jruby\_drip with the following content:

```bash
#!/usr/bin/env bash

if [[ "${rvm_ruby_string}" =~ "jruby" ]]
then
  export JAVACMD=`which drip`
  export DRIP_INIT_CLASS=org.jruby.main.DripMain
  
  # settings from: https://github.com/jruby/jruby/wiki/Improving-startup-time
  export JRUBY_OPTS="-J-XX:+TieredCompilation -J-XX:TieredStopAtLevel=1 -J-noverify" 
fi
```

Then you'll need to make that file executable:

```bash
chmod +x $rvm_path/hooks/after_use_jruby_drip
```

