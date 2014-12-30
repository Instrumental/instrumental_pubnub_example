require 'instrumental_agent'
require 'pubnub'

module Instrumental
  module PubNub
    class Relay

      def initialize(pubnub_subscribe_key, pubnub_channel_name, instrumental_api_key, key_prefix, logger)
        @logger        = logger
        @agent         = Instrumental::Agent.new(instrumental_api_key)
        @pubnub        = Pubnub.new(:subscribe_key    => pubnub_subscribe_key,
                                    :error_callback   => method(:on_error),
                                    :connect_callback => method(:on_connect))
        @channel       = pubnub_channel_name
        @prefix        = key_prefix
        @disconnecting = false
      end

      def run!
        @pubnub.subscribe(:channel => @channel, :callback => method(:on_message))
        block_for_messages
      end

      def disconnect!
        @disconnecting = true
        @pubnub.leave(:channel => @channel, :callback => method(:on_leave))
      end

      def on_leave(msg)
        shutdown
      end

      def on_message(msg)
        data              = msg.message
        submitted_metrics = case data
                            when Hash
                              data.flat_map do |k, v|
                                gauge_array([@prefix, k].join("."), Array(v))
                              end
                            when Array
                              gauge_array(@prefix, data)
                            else
                              if data.to_s.size > 0
                                gauge_metric(@prefix, data.to_s)
                              end
                            end
        submitted_metrics = Array(submitted_metrics).compact
        if submitted_metrics.size > 0
          info "Sent #{submitted_metrics.size} metrics"
        end
      end

      def gauge_array(name, val)
        if val.size != 1
          val.map.with_index do |measurement, i|
            gauge_metric([name, i].join("."), measurement)
          end
        else
          gauge_metric(name, val.first)
        end
      end

      def gauge_metric(name, value)
        case value
        when Numeric
          debug "Gauge metric %s with value %s" % [name.inspect, value.inspect]
          @agent.gauge(name, value)
          name
        else
          warn "Not measuring metric %s, not a numeric value (%s)" % [name.inspect, value.inspect]
          nil
        end
      end

      def on_error(msg)
        error "%s (%s)" % [msg.message, msg.response.inspect]
        if @disconnecting
          shutdown
        end
      end

      def on_connect(msg)
        info "Connected"
      end

      private

      %w{warn debug info fatal error}.each do |level|
        define_method(level.to_sym) do |msg|
          @logger.send(level.to_sym, msg)
        end
      end

      def force_shutdown_after_wait(wait_time = 10)
        EM.add_timer(wait_time) do
          info "Forcing shutdown"
          shutdown
          exit 1
        end
      end

      def eventmachine_running?
        EM.reactor_running? && EM.reactor_thread
      end

      def block_for_messages
        sleep 1 while !eventmachine_running?
        EM.reactor_thread.join
      end

      def shutdown
        EM.stop_event_loop
      end

    end
  end
end
