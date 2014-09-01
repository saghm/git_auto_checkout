require 'git_auto_checkout/git_commit'

module GitAutoCheckout
  class GitCheckoutHelper
    # Internal: Gets the Array of GitCommits.
    attr_reader :commits

    # Internal: Intialize a CheckoutHelper.
    def initialize(page_size = 8)
      @page_size = page_size
      log        = `git log`.split("\n")
      
      parse_all_commits(log)
      get_git_branches
    end

    # Internal: Prompt the user to select a past commit or quit, and checkout
    # the past commit if one was selected.
    #
    # Returns nothing.
    def make_commit
      commit_or_branch = prompt_user_until_quit_or_commit_selection
      return unless commit_or_branch

      git_checkout(commit_or_branch)
    end

    private

    # Internal: Go through all the commits and parses out the hash strings and
    # messages.
    #
    # log - String output of `git log`.
    #
    # Returns nothing (adds commits directly to instance variable.
    def parse_all_commits(log)
      @commits  = []
      @commits << parse_one_commit(log) until log.empty?

      # Show commits newest to oldest.
      @commits.reverse
    end

    # Internal: Prompts user for selection of a past commit.
    #
    # idx   - Which commit index to start listing from.
    # error - Incorrect input String previously given, or nil if there was none.
    #
    # Returns hash String of selected commit, or false if none was chosen.
    # Raises error (through #parse_one_commit if the log String is malformed
    # (e.g. each commit message is not preceded and succeeded by an empty line).
    # Raises error (through #parse_commit_hash) if no commit was found.
    def prompt_user_until_quit_or_commit_selection(idx = 0, error=false)
      print_commit_prompt(idx, error)

      selection = gets.chomp!
      number    = selection.to_i
      selection = number if selection == '0' || number != 0

      return case selection
             when 'b'
               prompt_user_until_quit_or_branch_selection
             when 'q'
               false
             when 'p'
               idx = [idx - @page_size, 0].max
               prompt_user_until_quit_or_commit_selection(idx, false)
             when 'n'
               idx = [idx + @page_size, commits.size - @page_size].min
               idx = [idx, 0].max
               prompt_user_until_quit_or_commit_selection(idx, false)
             when idx...idx + @page_size
               @commits[selection.to_i].hash_string
             else
               selection = invalid_entry(selection)
               prompt_user_until_quit_or_commit_selection(idx, selection)
             end
    end

    # Internal: Report error if there is one, and prompts user for input.
    #
    # idx   - Which commit index to start listing from.
    # error - Incorrect input String previously given, or nil if there was none.
    #
    # Returns nothing.
    def print_commit_prompt(idx, error)
      system 'clear'

      puts error if error
      puts 'Enter a number to checkout that commit'
      puts 'Enter "b" to see a list of branches to checkout'
      puts 'Enter "p" to scroll to the previous set of commits'
      puts 'Enter "n" to scroll to the next set of commits'
      puts 'Enter "q" to quit without checking out anything'
      puts '----------------------------------------------'

      @commits[idx...idx + @page_size].each_with_index do |commit, i|
        puts "#{idx + i}: #{commit.message}"
      end
    end

    # Internal: Remove and parse the first commit from the log and returns it
    # serialized into a GitCommit.
    #
    # log - String output of `git log`.
    #
    # Returns the GitCommit parsed from the log.
    # Raises error if the log String is malformed (e.g. each commit message is
    # not preceded and succeeded by an empty line).
    # Raises error (through #parse_commit_hash) if no commit was found.
    def parse_one_commit(log)
      commit, idx = parse_commit_hash(log)
      log.slice!(0, idx)

      log.each_with_index do |line, i|
        next unless line.empty?

        commit.message = log[i + 1].strip
        raise 'weird message ending' if log[i + 2] && !log[i + 2].empty?

        log.slice!(0, i + 2)

        return commit
      end

      raise 'no message found'
    end

    # Internal: Parse the hash string of the first commt in the log.
    #
    # log - String output of `git log`.
    #
    # Returns the newly created GitCommit and the index of the first line after
    # the hash String found.
    # Raises error if no commit was found.
    def parse_commit_hash(log)
      commit = GitCommit.new

      log.each_with_index do |line, i|
        line = line.split
        next unless line.first == 'commit'

        commit.hash_string = line.last
        return commit, i + 1
      end

      raise 'no commit found'
    end

    # Internal: Checkouts out a past commit specified by the hash string.
    #
    # commit_hash_string - String of past git commit to checkout.
    #
    # Returns nothing.
    def git_checkout(commit_or_branch)
      system 'clear'
      `git checkout #{commit_or_branch}`
    end

    def get_git_branches
      @branches = `git branch`.split("\n").reject { |branch| branch.chr == "*" }
      @branches.map!(&:strip)
    end

    def prompt_user_until_quit_or_branch_selection(idx = 0, error=false)
      if @branches.empty?
        return prompt_user_until_quit_or_commit_selection(
                 0,
                 'No other branches exist'
               )
      end

      print_branch_prompt(idx, error)

      selection = gets.chomp!
      number    = selection.to_i
      selection = number if selection == '0' || number != 0

      return case selection
             when 'c'
               prompt_user_until_quit_or_commit_selection
             when 'q'
               false
             when 'p'
               idx = [idx - @page_size, 0].max
               prompt_user_until_quit_or_branch_selection(idx, false)
             when 'n'
               idx = [idx + @page_size, commits.size - @page_size].min
               prompt_user_until_quit_or_branch_selection(idx, false)
             when idx...idx + @page_size
               @branches[selection.to_i]
             else
               selection = invalid_entry(selection)
               prompt_user_until_quit_or_branch_selection(idx, selection)
             end
    end


    def print_branch_prompt(idx, error)
      system 'clear'

      puts error if error
      puts 'Enter a number to checkout that branch'
      puts 'Enter "c" to see a list of commits to checkout'
      puts 'Enter "p" to scroll to the previous set of commits'
      puts 'Enter "n" to scroll to the next set of commits'
      puts 'Enter "q" to quit without checking out anything'
      puts '----------------------------------------------'

      @branches[idx...idx + @page_size].each_with_index do |branch, i|
        puts "#{idx + i}: #{branch}"
      end
    end

    def invalid_entry(error)
      "Invalid entry \"#{error}\"; try again"
    end
  end # End class
end # End module
1
