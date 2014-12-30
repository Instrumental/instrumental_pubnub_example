require 'instrumental_agent'
require 'logger'

module Instrumental
  module PubNub
    class Relay

      def initialize(pubnub_subscribe_key, pubnub_channel_name, instrumental_api_key, key_prefix = nil)
        @logger  = Logger.new(STDOUT)
        @agent   = Instrumental::Agent.new(instrumental_api_key)
        @pubnub  = Pubnub.new(:subscribe_key => pubnub_subscribe_key, :error_callback => method(:on_error), :connect_callback => method(:on_connect))
        @channel = pubnub_channel_name
        @prefix  = key_prefix
      end

      def run!
        @pubnub.subscribe(:channel => @channel, :callback => method(:on_message))
        EM.run
      end

      def disconnect!
        @pubnub.leave(:channel => @channel, :callback => method(:on_leave))
      end

      def on_leave(msg)
      end

      def on_message(msg)
        @logger.info msg.inspect
      end

      def on_error(msg)
        @logger.error "[ERROR]: %s" % msg
      end

      def on_connect(msg)
        @logger.info "[INFO]: Connected"
      end

    end
  end
end
