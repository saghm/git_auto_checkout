#!/usr/bin/env ruby

require 'git_auto_checkout/git_checkout_helper'

module GitAutoCheckout
  module_function

  def run
    if `git rev-parse --is-inside-work-tree 2>&1`.split.first == "fatal:"
      $stderr.puts "Error: current directory is not a git repository"
      exit 1
    end

    git_checkout_helper = GitCheckoutHelper.new
    git_checkout_helper.make_commit
  end
end
