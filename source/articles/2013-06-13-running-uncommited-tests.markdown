---
title: Running Changed Tests
author: Robert Jackson
date: 2013-06-13
published: false
tags: minitest, rspec, testing, git
---

Using small feature branches definitely seems like the best way to go for local development with git. This makes it very easy to keep distinct features separate and just merge them back to `master` when the feature is completed. How can we leverage the awesomeness of `git` to run only the tests that have changed from one branch to another?

READMORE

## Basic Idea

I rely on CI and pre-deployment checks to run the whole test suite prior to a production deploy, but at any given time I want to be able to run the tests that have been added or changed since branching. A tool like `guard` can be setup to do exactly what I am proposing, but as stated in previous articles I prefer to run my tests from within `vim` using an easy to remember mapping (for me that is usually `<leader>t`). I find it very simple to simply add that mapping as I need to so that it can be tailored for a particular projects test setup (at some point in the future I may switch to [dispatch.vim](https://github.com/tpope/vim-dispatch)).

## Get Changed Files

If we want to only run the new/updated files between branches we are going to need a list of them, right? OK, so how can we make `git` do this for us? There are a few different ways to make `git` give us the information that we need, but the simplest way that I can think of is just to use the `diff` subcommand ([see documentation](http://git-scm.com/docs/git-diff)) and specify that we only want the filenames.  Something like this should be a good start:

```sh
git diff --name-only
```

With this command we are going to get a list of files with uncommitted changes, but what we want is a list of files changed between our working directory and another branch. It turns out it is **super** easy as `git diff` can take a branch name (or specific commit) as a parameter:

```sh
git diff --name-only master
```

That command outputs a complete listing of files changed from `master` to our working directory.

## Filtering for Test Files

There is one glaring issue here: we don't really care about **all** of the files changed, we only want a listing of the test files that we can pass off to our test runner of choice. It turns out that `git diff` can do this too! We can provide a list of paths to `git diff` and it will filter the results to just these directories. We have to separate the paths from the rest of the command by putting `--` between the branch name and paths:

```sh
git diff --name-only master -- spec test
```

### Broken Edge Cases

Here are a few edge cases where this technique has caused issues for me:

* When tests have been added to master but are not in the current branch they need to be excluded because `git` thinks these files are 'deleted'. The `--diff-filter` option tells `git` to ignore 'deleted' files:

```sh
git diff --diff-filter=ACMRTUXB --name-only master -- spec test
```

* When using `factory_girl` and files have been added to `spec/factories` the factory files cannot be passed directly along with other test files that require them without getting an error for `Factory already registered:`. This can be fixed by filtering out any files from `spec/factories` using `grep -v`:

```sh
git diff --diff-filter=ACMRTUXB --name-only master -- spec test | grep -v spec/factories
```

* Any new files that are not added to `git` yet will not be ran. In order for `git diff` to report a new file we need to add them to the index (usually via `git add`).

## Simplifying

Obviously, the current version of our command is pretty difficult to remember and/or type so we need a way to simplify the command into something we can easily remember. We can leverage `git`'s aliases to handle this for us: 

```sh
git config --global alias.list-branch-tests "! git diff --diff-filter=ACMRTUXB --name-only master -- spec test | grep -v spec/factories "
```
Please note that the example given here will create a global `git` alias, but if you want specific aliases per project just exclude the `--global` flag.

## Running the Tests

Now that we have a list of the test files that have changed we need to figure out how to run them. It turns out to be pretty easy for both `rspec` and `minitest`:

### RSpec

The `rspec` command that comes with the gem accepts a list of files to run (when no files are specified it will run all files that match `spec/**/*_spec.rb`). So all we need to do is call `rspec` and pass it the output of our command:

```sh
rspec `git list-branch-tests`
```

### Minitest

Minitest does not come with a binary command that we can use, but it is pretty easy to use the standard `ruby` executable's options to do what we want:

```sh
git list-branch-tests | ruby -r minitest/autorun -ne 'require "#{Dir.pwd}/#{$_.chomp}"'
```

This is basically, equivalent to the `rspec` command listed above. The git command makes sense, but what are all of those options to `ruby`?

* `-r minitest/autorun` - This requires the `minitest/autorun` library which allows us to require `minitest` tests and run them once they have been loaded.
* `-n` - This places the script being run (in this case what we are passing to `-e`, but it could just as easily be a file) in a `while gets` loop. This means that our script will be run once for each input line (which in our case will be once for each file identified by our `git` alias).
* `-e` - This simply `eval`'s the string that you pass it, and is most likely the one you are most familiar with.

## Conclusion

While the actual command to run is somewhat complicated once you factor in the various edge cases, the fact that the basic concept is fairly straight forward is a real testament to the power of `git`. 

I have been using this technique (mostly with `rspec`) for a while now, and it has been working well for me.

