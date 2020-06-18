# frozen_string_literal: true

require 'thor'

module DockerComposeAutomation
  # Base configurations for a dockerfile
  class Configuration < Thor::Group
    include Thor::Actions

    # Invert so we can call TEST_FRAMEWORK_OPTIONS[1] #=> :rspec
    DISTROS = {
      debian: 1,
      alpine: 2
    }.invert

    # Call it DOCKER_RUBY_VERSIONS to avoid name collision
    DOCKER_RUBY_VERSIONS = {
      '2.5': 1,
      '2.6': 2,
      '2.7': 3
    }.invert

    attr_accessor :distro, :ruby_version

    def ruby_versions
      DOCKER_RUBY_VERSIONS
    end

    def distros
      DISTROS
    end

    def ask_questions
      ask_for_docker_ruby_version if ruby_version.nil?
      ask_for_distro if distro.nil?
    end

    private

    def ask_for_input(question, answers)
      provide_input = "Please provide a number (1-#{answers.length})"

      allowable_answers = answers.keys
      loop do
        say "\n#{question}"
        answers.each { |num, string| say "#{num}.) #{string}", :cyan }
        answer = ask("\n#{provide_input}:\n ", :magenta).strip.to_i

        return answer if allowable_answers.include?(answer)

        say "\nInvalid input given", :red
      end
    end

    def ask_for_docker_ruby_version
      question = 'What ruby version would you like to use?'

      answers = ruby_versions

      input = ask_for_input(question, answers)

      @ruby_version = answers[input]
    end

    def ask_for_distro
      question = 'What linux distro would you like use?'

      answers = distros

      input = ask_for_input(question, answers)

      @distro = answers[input]
    end
  end
end
