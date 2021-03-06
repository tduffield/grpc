# Copyright 2017 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# GRPC contains the General RPC module.
module GRPC
  ##
  # GRPC RSpec base module
  #
  module Spec
    ##
    # A module that is used for providing generic helpers across the
    # GRPC test suite
    #
    module Helpers
      # Shortcut syntax for a GRPC RPC Server
      RpcServer = GRPC::RpcServer

      ##
      # Build an RPC server used for testing
      #
      def build_rpc_server(server_opts: {},
                           client_opts: {})
        @server = RpcServer.new({ poll_period: 1 }.merge(server_opts))
        @port = @server.add_http2_port('0.0.0.0:0', :this_port_is_insecure)
        @host = "0.0.0.0:#{@port}"
        @client_opts = client_opts
        @server
      end

      ##
      # Run services on an RPC server, yielding to allow testing within
      #
      # @param [RpcServer] server
      # @param [Array<Class>] services
      #
      def run_services_on_server(server, services: [])
        services.each do |s|
          server.handle(s)
        end
        t = Thread.new { server.run }
        server.wait_till_running

        yield

        server.stop
        t.join
      end

      ##
      # Build an insecure stub from a given stub class
      #
      # @param [Class] klass
      # @param [String] host
      #
      def build_insecure_stub(klass, host: nil, opts: nil)
        host ||= @host
        opts ||= @client_opts
        klass.new(host, :this_channel_is_insecure, **opts)
      end
    end
  end
end
