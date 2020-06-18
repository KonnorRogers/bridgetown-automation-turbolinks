# frozen_string_literal: true

lib_name = 'bridgetown-automation-docker-compose'
require_relative "#{lib_name}/configuration"
require_relative "#{lib_name}/utils"

module DockerComposeAutomation
  FILES = %w[docker-compose.yml .dockerignore Dockerfile docker.env].freeze
end
