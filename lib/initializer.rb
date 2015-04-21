module Initializer
  def self.run
    Thread.abort_on_exception = true

    require_config
    require_lib
    require_initializers
    require_models
    require_workers
  end

  def self.require_config
    require_relative "../config/config"
  end

  def self.require_lib
    require! %w(
      lib/utils/**/*
      lib/serializers/base
      lib/serializers/**/*
      lib/endpoints/base
      lib/endpoints/**/*
      lib/mediators/base
      lib/mediators/**/*
      lib/routes
    )
  end

  def self.require_models
    require! %w(
      lib/models/**/*
    )
  end

  def self.require_workers
    require! %w(
      lib/workers/**/*
    )
  end

  def self.require_initializers
    Pliny::Utils.require_glob("#{Config.root}/config/initializers/*.rb")
  end

  def self.require!(globs)
    globs = [globs] unless globs.is_a?(Array)
    globs.each do |f|
      Pliny::Utils.require_glob("#{Config.root}/#{f}.rb")
    end
  end
end

Initializer.run
