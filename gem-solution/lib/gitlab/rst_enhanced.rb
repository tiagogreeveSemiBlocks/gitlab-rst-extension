# frozen_string_literal: true

require_relative "rst_enhanced/version"

require "open3"
require "logger"

module Gitlab
  # Enhanced reStructuredText rendering for GitLab.
  #
  # GitLab already renders `.rst` files by spawning a python3 docutils
  # process through the gitlab-markup gem, but the output has no styling
  # for admonitions, tables, sidebars and friends. This module wraps an
  # enhanced docutils renderer (`bin/rst2html-enhanced`) that keeps
  # docutils' semantic CSS classes, pairs it with an RST stylesheet, and
  # hardens the same security restrictions GitLab applies.
  module RstEnhanced
    class Error < StandardError; end

    SCRIPT = File.expand_path("../../bin/rst2html-enhanced", __dir__)
    PYTHON = ENV.fetch("RST_ENHANCED_PYTHON", "python3")
    DEFAULT_TIMEOUT = 10 # seconds

    class << self
      # Render RST content into an HTML fragment.
      MAX_BYTES = 10 * 1024 * 1024

      def render(content, timeout: DEFAULT_TIMEOUT)
        raise Error, "content too large" if content.to_s.bytesize > MAX_BYTES

        out, err, status = Open3.capture3(PYTHON, SCRIPT, stdin_data: content.to_s)

        unless status.success?
          raise Error, "rst2html-enhanced failed (exit #{status.exitstatus}): #{err.to_s.strip[0, 500]}"
        end

        out
      end

      # Wire the enhanced renderer into gitlab-markup.
      #
      # gitlab-markup exposes a single public entry point:
      #   Markup.render(filename, content)
      # We wrap it so that `.rst` files are handled by the enhanced
      # renderer while everything else falls through untouched. This
      # works regardless of the gem's internal implementation details.
      #
      # Call from `config/initializers/rst_enhanced.rb`:
      #   require "/usr/local/lib/gitlab-rst-enhanced/lib/gitlab/rst_enhanced"
      #   Gitlab::RstEnhanced.install!
      def install!(logger: default_logger)
        markup = markup_module
        unless markup && markup.respond_to?(:render)
          logger.warn("[rst-enhanced] gitlab-markup not loaded; call install! after it is required")
          return false
        end

        original_render = markup.method(:render)
        markup.define_singleton_method(:render) do |filename, content, *args|
          if File.extname(filename.to_s).downcase == ".rst" && content.is_a?(String)
            Gitlab::RstEnhanced.render(content)
          else
            original_render.call(filename, content, *args)
          end
        end

        logger.info("[rst-enhanced] enhanced RST rendering installed")
        true
      end

      private

      def markup_module
        if defined?(GitHub::Markup)
          GitHub::Markup
        elsif defined?(Gitlab::Markup)
          Gitlab::Markup
        end
      end

      def default_logger
        Logger.new($stdout).tap { |l| l.level = Logger::INFO }
      end
    end
  end
end
