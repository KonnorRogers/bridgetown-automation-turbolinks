# frozen_string_literal: true

require 'test_helper'
require 'open3'

GITHUB_REPO_NAME = 'bridgetown-automation-docker-compose'
BRANCH = `git branch --show-current`.chomp.freeze || 'master'

module DockerComposeAutomation
  class IntegrationTest < Minitest::Test
    def setup
      Rake.rm_rf(TEST_APP)
      Rake.mkdir_p(TEST_APP)
    end

    def read_test_file(filename)
      File.read(File.join(TEST_APP, filename))
    end

    def read_template_file(filename)
      File.read(File.join(TEMPLATES_DIR, "#{filename}.tt"))
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

        exit_status = wait_thr.value
      end
    end

    def run_assertions(ruby_version:, distro:)
      FILES.each do |file|
        next if file == 'Dockerfile'

        test_file = read_test_file(file)
        template_file = read_template_file(file)
        assert_match test_file, template_file
      end

      # Check if ruby version loaded properly
      dockerfile = read_test_file('Dockerfile')
      ruby_regex = /FROM ruby:(?<ruby_version>\d+\.\d+)/
      dockerfile_ruby_version = dockerfile.match(ruby_regex)[:ruby_version]
      assert_equal dockerfile_ruby_version, ruby_version

      # Check if distro loaded properly
      distro_regex = /#{ruby_regex}[- ](?<distro>\w+)\s+/
      distro_match = dockerfile.match(distro_regex)
      assert distro_match

      # Use the match group, if it doesnt exist, it means its debian based.
      docker_distro = dockerfile.match(distro_regex)[:distro].to_sym
      docker_distro = :debian if docker_distro == 'as'
      assert_equal(distro, docker_distro)
    end

    def create_inputs(ruby_version:, distro:)
      distros = Configuration::DISTROS.invert
      ruby_versions = Configuration::DOCKER_RUBY_VERSIONS.invert

      distro_input = distros[distro].to_s
      ruby_version_input = ruby_versions[:"#{ruby_version}"].to_s

      { ruby_version: ruby_version_input, distro: distro_input }
    end

    def test_it_works_with_local_automation
      Rake.cd TEST_APP

      Rake.sh('bundle exec bridgetown new . --force ')

      distro = :alpine
      ruby_version = '2.6'

      inputs = create_inputs(distro: distro, ruby_version: ruby_version)

      ruby_version_input = inputs[:ruby_version]
      distro_input = inputs[:distro]

      run_command(ruby_version_input, distro_input) do
        'bridgetown apply ../bridgetown.automation.rb'
      end

      run_assertions(ruby_version: ruby_version, distro: distro)
    end

    # Have to push to github first, and wait for github to update
    def test_it_works_with_remote_automation
      Rake.cd TEST_APP

      github_url = 'https://github.com'
      user_and_reponame = "ParamagicDev/#{GITHUB_REPO_NAME}/tree/#{BRANCH}"

      file = 'bridgetown.automation.rb'

      url = "#{github_url}/#{user_and_reponame}/#{file}"

      distro = :alpine
      ruby_version = '2.6'

      inputs = create_inputs(distro: distro, ruby_version: ruby_version)

      ruby_version_input = inputs[:ruby_version]
      distro_input = inputs[:distro]

      Rake.sh('bundle exec bridgetown new . --force ')

      run_command(ruby_version_input, distro_input) do
        "bridgetown apply #{url}"
      end

      run_assertions(ruby_version: ruby_version, distro: distro)
    end
  end
end
