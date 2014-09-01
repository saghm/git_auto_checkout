# Installation

## Method 1: Install from Rubygems

### Prerequisites

You must have the `gem` command available on your system.

### Steps

Run the following command in your terminal:

1. `gem install git_auto_checkout`

## Method 2: Manually install gem

The repostory is a typical Ruby gem, so it can be installed by cloning and
locally building the .gem file. Follow these steps to install the gem manually:

### Prerequisites

You must have git installed on your system, as well as the `gem` command
available.

### Steps

Run the following commnads in your terminal

1. `git clone https://github.com/saghmrossi/git_auto_checkout/`
2. `cd git_auto_checkout`
3. `gem build git_auto_checkout.gemspec`
4. `gem install --local git_auto_checkout*.gem`

You no longer need the repository after the gem is installed.

# Usage

Assuming your gem paths are set up properly, the gem installation makes the
`git_auto_checkout` executable available to you from anywhere. Run it in a
directory that is a git repository and follow the prompts to checkout branches
or past commits.
