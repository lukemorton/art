module Art
  module Gateway
    module Interface
      def self.included(base)
        base.class_eval do
          def self.[](gateway_class)
            gateway_interface = self

            Class.new do
              gateway_interface.exposes.each do |expose|
                define_method(expose.method) do |*args|
                  gateway = gateway_class.new
                  gateway.record_class = @record_class
                  record = gateway.send(expose.method, *args)
                  Art::Domain[expose.return_class].new(record) unless record.nil?
                end
              end

              def initialize(record_class)
                @record_class = record_class
              end
            end
          end

          def self.exposes
            @exposes
          end

          def self.expose(method)
            @exposes ||= []
            Expose.new(method).tap { |expose| @exposes << expose }
          end
        end
      end

      class Expose
        attr_reader :method, :args, :return_class

        def initialize(method)
          @method = method
        end

        def with(*args)
          @args = args
          self
        end

        def and_return(return_class)
          @return_class = return_class
          self
        end
      end
    end
  end

  class Domain
    def self.[](domain_class)
      Class.new(domain_class) do
        def initialize(record)
          methods = self.class.superclass.instance_methods(false)

          methods.select { |method| method =~ /\=$/ }.each do |writer|
            reader = writer.to_s.chomp('=')
            self.send(writer, record.send(reader)) if record.respond_to?(reader)
          end
        end
      end
    end
  end
end
