# frozen_string_literal: true

require 'test_helper'

GITHUB_REPO_NAME = 'bridgetown-automation-turbolinks'
BRANCH = `git branch --show-current`.chomp.freeze || 'master'

class IntegrationTest < Minitest::Test
  def setup
    Rake.rm_rf(TEST_APP)
    Rake.mkdir_p(TEST_APP)
  end

  def read_test_file(filename)
    File.read(File.join(TEST_APP, filename))
  end

  # If no block given, use the first input as the command
  def run_command(*inputs)
    cmd = yield if block_given? || inputs.shift!

    Open3.popen3(cmd) do |stdin, stdout, _stderr, wait_thr|
      wait_thr.pid

      inputs.flatten.each { |input| stdin.puts(input) }

      stdout.each_line do |line|
        puts line
      end
    end
  end

  def run_assertions; end

  def test_it_works_with_local_automation
    Rake.cd TEST_APP

    Rake.sh('bundle exec bridgetown new . --force --apply="../bridgetown.automation.rb"')

    run_assertions
  end

  # Have to push to github first, and wait for github to update
  def test_it_works_with_remote_automation
    Rake.cd TEST_APP

    github_url = 'https://github.com'
    user_and_reponame = "ParamagicDev/#{GITHUB_REPO_NAME}/tree/#{BRANCH}"

    file = 'bridgetown.automation.rb'

    url = "#{github_url}/#{user_and_reponame}/#{file}"

    Rake.sh('bundle exec bridgetown new . --force ')
    Rake.sh("bridgetown apply #{url}")

    run_assertions
  end
end
