module Spec
  module Matchers
    class YieldWith #:nodoc:
      def initialize(*args, &block)
        @args_expectation = Spec::Mocks::ArgumentExpectation.new(args, &block)
        @yielded = false
        @args_match = false
      end
      
      def matches?(given_proc)
        begin
          given_proc.call do |*given_args|
            @given_args = given_args
            @yielded = true
            @args_match = @args_expectation.args_match? @given_args
          end
        rescue LocalJumpError => e
          raise if e.message != "no block given"
        end
        return @yielded && @args_match
      end

      def failure_message_for_should
        if @yielded
          error_generator = Spec::Mocks::ErrorGenerator.new(nil, nil)
          expected_args = error_generator.send(:format_args, *@args_expectation.args)
          actual_args = @given_args.empty? ? "(no args)" : error_generator.send(:format_args, *@given_args)
          "expected to yield with #{expected_args} but received it with #{actual_args}"
        else
          "expected to yield"
        end
      end

      def failure_message_for_should_not
        if @yielded
          error_generator = Spec::Mocks::ErrorGenerator.new(nil, nil)
          expected_args = error_generator.send(:format_args, *@args_expectation.args)
          "expected not to yield with #{expected_args}"
        else
          "expected not to yield"
        end
      end
      
      def description
        "yield"
      end
    end
 
    # :call-seq:
    #   should yield_with()
    #   should yield_with(1, 2, 3)
    #   should yield_with('foo, 'bar')
    #   should yield_with(no_args())
    #   should yield_with(an_instance_of(String))
    #   should yield_with(any_args())
    #   should yield_with(nil, nil) {|x, y| x % y == 0}
    #   should_not yield_with()
    #   should_not yield_with(1, 2, 3)
    #
    # With no arguments, matches if the block yields and passes no arguments.
    # With arguments, matches only if the block yields and passes arguments that match.
    # 
    # Pass an optional block to perform alternative verifications on the arguments matched (using a block short circuits
    # the argument matchers, so only use a block to perform checks that are less restrictive than your argument matchers).
    #
    # Note that you must explicitly pass the block to be yielded, otherwise you will receive a LocalJumpError.
    #
    # == Examples
    #
    #   lambda {|block| do_something_that_yields(&block) }.should yield_with
    #   lambda {|block| do_something_that_yields_42(&block) }.should yield_with(42)
    #   lambda {|block| do_something_that_yields_strings(&block) }.should yield_with(an_instance_of(String))
    #
    #   lambda {|block| do_something_that_will_not_yield(&block) }.should_not yield_with
    #   lambda {|block| do_something_that_will_not_yield(&block) }.should_not yield_with(anything())
    def yield_with(sym=nil)
      Matchers::YieldWith.new(sym)
    end
  end
end
