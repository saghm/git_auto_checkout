#!/usr/bin/env ruby

require 'git_auto_checkout/git_checkout_helper'

module GitAutoCheckout
  module_function

  def run
    git_checkout_helper = GitCheckoutHelper.new
    git_checkout_helper.make_commit
  end
end
