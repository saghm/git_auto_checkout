# Installation

The repostory is a typical Ruby gem, so it can be installed by cloning and
locally building the .gem file. As of right now, the gem is *not* published on
rubygems.org, so `gem install git_auto_checkout` won't work. I expect to publish
it there sometime soon, but for now, folllow these steps to install:

## Prerequisites

You must have git installed on your system, as well as the "gem" command
available.

## Then run the following commands in your terminal**

1. `git clone https://github.com/saghmrossi/git_auto_checkout/`
2. `cd git_auto_checkout`
3. `gem build git_auto_checkout.gemspec`
4. `gem install --local git_auto_checkout*.gem`

# Usage

Assuming your gem paths are set up properly, the gem installation makes the
"git_auto_checkout" executable available to you from anywhere. Run it in a
directory that is a git repository and follow the prompts to checkout branches
or past commits.
