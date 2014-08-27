require 'git_auto_checkout/git_commit'

module GitAutoCheckout
  class GitCheckoutHelper
    # Internal: Gets the Array of GitCommits.
    attr_reader :commits

    # Internal: Intialize a CheckoutHelper.
    def initialize
      log = %x(git log).split("\n")
      parse_all_commits(log)
    end

    # Internal: Prompt the user to select a past commit or quit, and checkout the
    # past commit if one was selected.
    #
    # Returns nothing.
    def make_commit
      old_commit = prompt_user_until_quit_or_selection
      return unless old_commit

      git_checkout_old_commit(old_commit)
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
    end

    # Internal: Prompts user for selection of a past commit.
    #
    # idx   - Which commit index to start listing from.
    # error - Incorrect input String previously given, or nil if there was none.
    #
    # Returns hash String of selected commit, or false if none was chosen.
    # Raises error (through #parse_one_commit if the log String is malformed (e.g.
    # each commit message is not preceded and succeeded by an empty line).
    # Raises error (through #parse_commit_hash) if no commit was found.
    def prompt_user_until_quit_or_selection(idx = 0, error=false)
      print_prompt(idx, error)

      selection = gets.chomp!
      number    = selection.to_i
      selection = number if selection == '0' || number != 0

      return case selection
             when 'q'
               false
             when 'p'
               idx = [idx - 4, 0].max
               prompt_user_until_quit_or_selection(idx, false)
             when 'n'
               idx = [idx + 4, commits.size - 4].min
               prompt_user_until_quit_or_selection(idx, false)
             when idx...idx + 4
               commits[selection.to_i].hash_string
             else
               prompt_user_until_quit_or_selection(idx, selection)
             end
    end

    # Internal: Report error if there is one, and prompts user for input.
    #
    # idx   - Which commit index to start listing from.
    # error - Incorrect input String previously given, or nil if there was none.
    #
    # Returns nothing.
    def print_prompt(idx, error)
      system 'clear'

      puts "Invalid entry \"#{error}\"; try again" if error
      puts 'Enter a number to revert to that commit'
      puts 'Enter "b" to see a list of branches to checkout'
      puts 'Enter "p" to scroll to the previous set of commits'
      puts 'Enter "n" to scroll to the next set of commits'
      puts 'Enter "q" to quit without reverting'
      puts '----------------------------------------------'

      @commits[idx...idx + 4].each_with_index do |commit, i|
        puts "#{idx + i}: #{commit.message}"
      end
    end

    # Internal: Remove and parse the first commit from the log and returns it
    # serialized into a GitCommit.
    #
    # log - String output of `git log`.
    #
    # Returns the GitCommit parsed from the log.
    # Raises error if the log String is malformed (e.g. each commit message is not
    # preceded and succeeded by an empty line).
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
    def git_checkout_old_commit(commit_hash_string)
      system 'clear'
      %x(git checkout #{commit_hash_string})
    end
  end
end
