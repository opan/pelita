module Pelita
  module Operation
    class AttemptAdapter < Dry::Transaction::StepAdapters
      include Dry::Monads::Either::Mixin

      def call(step, input, *args)
        unless step.options[:catch]
          raise ArgumentError, "+attempt+ steps require one or more exception classes provided via +catch:+"
        end

        step.operation.call(input, *args)
      rescue *Array(step.options[:catch]) => e
        e = step.options[:raise].new(e.message) if step.options[:raise]
        input['errors'] = e
        Left(input)
      end
    end
  end
end
Dry::Transaction::StepAdapters.register :attempt, Pelita::Operation::AttemptAdapter.new
