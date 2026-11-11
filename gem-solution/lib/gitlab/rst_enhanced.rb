# frozen_string_literal: true

require_relative "rst_enhanced/version"

require "open3"
require "logger"

module Gitlab
  # Enhanced reStructuredText rendering for GitLab.
  #
  # GitLab renders `.rst` files by spawning a python3 docutils process
  # through the gitlab-markup gem. Two problems stand in the way of
  # full RST rendering:
  #
  # 1. Sanitization - Banzai's SanitizationFilter UNWRAPS <div> elements,
  #    so admonitions, sidebars, topics and rubrics collapse into plain
  #    paragraphs before rendering. This module extends the allowlist so
  #    docutils' structural markup survives.
  # 2. Output styling - docutils emits semantic CSS classes, but GitLab
  #    ships no CSS for them (handled by assets/rst-enhanced.css).
  module RstEnhanced
    class Error < StandardError; end

    SCRIPT = File.expand_path("../../bin/rst2html-enhanced", __dir__)
    PYTHON = ENV.fetch("RST_ENHANCED_PYTHON", "python3")
    DEFAULT_TIMEOUT = 10 # seconds
    MAX_BYTES = 10 * 1024 * 1024

    class << self
      # Render RST content into an HTML fragment.
      def render(content, timeout: DEFAULT_TIMEOUT)
        raise Error, "content too large" if content.to_s.bytesize > MAX_BYTES

        out, err, status = Open3.capture3(PYTHON, SCRIPT, stdin_data: content.to_s)

        unless status.success?
          raise Error, "rst2html-enhanced failed (exit #{status.exitstatus}): #{err.to_s.strip[0, 500]}"
        end

        out
      end

      # Wire the enhanced renderer into gitlab-markup and extend the
      # Banzai sanitization allowlist. Call from
      # config/initializers/rst_enhanced.rb:
      #
      #   require "gitlab/rst_enhanced"
      #   Gitlab::RstEnhanced.install!
      def install!(logger: default_logger)
        sanitized = extend_sanitization!(logger: logger)
        patched = patch_markup_render(logger)
        sanitized || patched
      end

      # gitlab-markup exposes one public entry point:
      #   Markup.render(filename, content)
      # Wrap it so .rst files go through the enhanced renderer while
      # everything else falls through untouched. Patching the public
      # API survives internal implementation changes in the gem.
      def patch_markup_render(logger)
        markup = markup_module
        unless markup && markup.respond_to?(:render)
          logger.warn("[rst-enhanced] gitlab-markup not loaded; call install! after it is required")
          return false
        end

        return true if markup.singleton_class.method_defined?(:rst_enhanced_patched)

        original_render = markup.method(:render)
        markup.define_singleton_method(:render) do |filename, content, *args|
          if File.extname(filename.to_s).downcase == ".rst" && content.is_a?(String)
            Gitlab::RstEnhanced.render(content)
          else
            original_render.call(filename, content, *args)
          end
        end
        markup.define_singleton_method(:rst_enhanced_patched) { true }

        logger.info("[rst-enhanced] enhanced RST rendering installed")
        true
      end

      # Banzai's SanitizationFilter unwraps <div> elements, which
      # destroys docutils' admonitions, sidebars and topics before CSS
      # can ever apply. GitLab supports extending the allowlist on
      # self-managed instances; register div/aside and the class
      # attribute so RST structure survives sanitization.
      def extend_sanitization!(logger: default_logger)
        return true if @sanitization_extended

        begin
          require "banzai"

          Banzai::Filter::SanitizationFilter.custom_allowlist do |allowlist|
            allowlist[:elements] = Array(allowlist[:elements]) | %w[div aside figure figcaption]
            allowlist[:attributes] ||= {}
            allowlist[:attributes][:all] = Array(allowlist[:attributes][:all]) | %w[class]
          end

          @sanitization_extended = true
          logger.info("[rst-enhanced] sanitization allowlist extended (div/aside + class attributes)")
          true
        rescue LoadError, NameError, StandardError => e
          logger.warn("[rst-enhanced] could not extend sanitization allowlist: #{e.message}")
          false
        end
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
