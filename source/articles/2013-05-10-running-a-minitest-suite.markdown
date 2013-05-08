---
title: Running a Minitest Suite
author: Robert Jackson
date: 2013-05-10
published: false
tags: minitest, testing, ruby
---

I have been enjoying [Minitest](https://github.com/seattle.rb/minitest) on a new project, but have been struggling with how I should be kicking off my test suite.  This is a pretty simple thing in rspec, but wasn't obvious with Minitest. I have explored a few different methods and figured that I might as well document them.


READMORE

## Requirements

While looking for a way to run the test suite I had a few specific requirements:

 1. Speed - Running the test suite shouldn't take longer than running the individual tests themselves.
 2. Simplicity - Reasoning about the process should be **VERY** simple.
 3. Minimal Output - Running the whole suite shouldn't clutter my test output: I only want to see the test results.
 4. Ease of Use - It should be very easy to trigger a full test run. (*I run my test suite directly from terminal VIM*)
 5. Runs all Tests/Specs - It should run the whole test suite.

## Methods Tested

The options that I have explored are:

* [minitest/autorun](#minitest-autorun)
* [rake/testtask](#rake-testtask)
* [custom rake task](#custom-rake-task) (*this is what I went with*)

## Sample Spec

Throughout this article I will be using the following sample spec file to illustrate the various methods of running a suite:

```ruby
describe "simple failing test" do
  it "fails" do
    assert 1 < 0
  end
end
```

## <a name="minitest-autorun"></a>Using `minitest/autorun`

Using requiring 'minitest/autorun' in any given spec file will run any specs after the file has been evaluated. So to run the sample spec file above you could run the following command:

```
ruby -r 'minitest/autorun' simple_spec.rb
```

Would output the following:

```
Run options: --seed 2852

# Running tests:

F

Finished tests in 0.000599s, 1669.4491 tests/s, 1669.4491 assertions/s.

  1) Failure:
  simple failing test#test_0001_fails [spec/simple_spec.rb:3]:
  Failed assertion, no message given.

  1 tests, 1 assertions, 1 failures, 0 errors, 0 skips
```

You could also add `require 'minitest/autorun'` to the beginning of the file, and run it with:

```
ruby simple_spec.rb
```

### Meets Requirements?

1. Yes, this method is super fast.
2. Yes, the source for how `Minitest.autorun` works is pretty straight forward (see [here](https://github.com/seattlerb/minitest/blob/2fa9185d765b0424203b78316f5d1df594aaf7ec/lib/minitest.rb#L35) and [here](https://github.com/seattlerb/minitest/blob/2fa9185d765b0424203b78316f5d1df594aaf7ec/lib/minitest.rb#L93)).
3. Yes, the only output is that of Minitest itself.
4. Yes, I can run it from VIM via `:!ruby spec/simple_spec.rb`.
5. **No**, running the tests via this method will only run the test on the files required. So if you just ran `ruby spec/simple_spec.rb` you would only get the test output for that particular set of specs (this is **super** useful, just not what I am going for here).

## <a name="rake-testtask"></a>Using `rake/testtask`

One of the most recommended ways that I have seen is to setup and use `Rake::TestTask` in your Rakefile. A sample Rakefile might look like:

```ruby
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/**/*_spec.rb']
end
```

By default this gives you a new rake task named 'test' that will run all of the spec files found. The output is much the same with one major exception: when the test suite fails Rake will raise an error and print out the backtrace.  Normally, you would want a backtrace from any errors thrown while running your tests, unfortunately this error actually has nothing to do with your test suite, and simply points to the line where `Rake::TestTask` itself calls `Kernel#fail`.

Here is a sample of the output:

```
Run options: --seed 57803

# Running tests:

F

Finished tests in 0.000538s, 1858.7361 tests/s, 1858.7361 assertions/s.

  1) Failure:
simple failing test#test_0001_fails [spec/simple_spec.rb:5]:
Failed assertion, no message given.

1 tests, 1 assertions, 1 failures, 0 errors, 0 skips
rake aborted!
Command failed with status (1): [ruby -I"lib:spec" -I"/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib" "/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/rake_test_loader.rb" "spec/simple_spec.rb" ]
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/testtask.rb:104:in `block (3 levels) in define'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/file_utils.rb:45:in `call'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/file_utils.rb:45:in `sh'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/file_utils_ext.rb:37:in `sh'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/file_utils.rb:82:in `ruby'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/file_utils_ext.rb:37:in `ruby'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/testtask.rb:100:in `block (2 levels) in define'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/file_utils_ext.rb:58:in `verbose'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/testtask.rb:98:in `block in define'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/task.rb:246:in `call'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/task.rb:246:in `block in execute'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/task.rb:241:in `each'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/task.rb:241:in `execute'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/task.rb:184:in `block in invoke_with_call_chain'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/task.rb:177:in `invoke_with_call_chain'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/task.rb:170:in `invoke'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/application.rb:143:in `invoke_task'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/application.rb:101:in `block (2 levels) in top_level'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/application.rb:101:in `each'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/application.rb:101:in `block in top_level'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/application.rb:110:in `run_with_threads'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/application.rb:95:in `top_level'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/application.rb:73:in `block in run'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/application.rb:160:in `standard_exception_handling'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/application.rb:70:in `run'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/bin/ruby_noexec_wrapper:14:in `eval'
/Users/rjackson/.rvm/gems/ruby-2.0.0-p0/bin/ruby_noexec_wrapper:14:in `<main>'
Tasks: TOP => rake_testtask
(See full trace by running task with --trace)
```

### Meets Requirements?

1. Yes, this method is super fast.
2. Maybe, the source for `Rake::TestTask` relies on a bunch of rake internal details. If you grok rake, then this may work for you.
3. **No**, running the test suite generates a bunch of useless noise.
4. Yes, I can run it from VIM via `:!rake test`.
5. Yes, this will run all files matching the glob passed in to the `FileList`.

## <a name="custom-rake-task"></a>Custom Rake Task

The `rake/testtask` method has all of the features that I have been looking for, but it has that **EXTREMELY** annoying backtrace distracting me from the real issues on every failing run. So I put together a super simple rake task that avoids the backtrace issue, but still allows me to run the whole test suite quickly:

```ruby
task :test do |t,args|
  $LOAD_PATH.unshift('lib','spec')
  FileList['spec/**/*_spec.rb'].each do |f|
    require "./#{f}"
  end
end
```

The only non-obvious thing here is that by default `rake/testtask` adds `lib` to your LOAD\_PATH, and in this case I also want `spec` added.

### Meets Requirements?

1. Yes, this method is super fast.
2. Yes, this method relies on rake's `FileList` to simply require the files found.
3. Yes, the only output displayed is from Minitest.
4. Yes, I can run it from VIM via `:!rake test`.
5. Yes, this will run all files matching the glob passed in to the `FileList`.
