require File.dirname(__FILE__) + '/../../spec_helper.rb'

module Spec
  module Matchers
    def non_yielding_subject
    end

    def no_arg_yielding_subject
      yield
    end

    def arg_yielding_subject
      yield 'ARG'
    end

    def other_arg_yielding_subject
      yield 561
    end

    describe YieldWith do
      shared_examples_for "no arguments" do
        it "should not match if lambda does not yield" do
          @matcher.matches?(lambda{|&block| non_yielding_subject(&block) }).should be_false
        end
    
        it "should match if lambda yields with no args" do
          @matcher.matches?(lambda{|&block| no_arg_yielding_subject(&block) }).should be_true
        end

        it "should not match if lambda yields with an argument" do
          @matcher.matches?(lambda{|&block| arg_yielding_subject(&block) }).should be_false
        end

        it "should provide a failure message for not yielding" do
          @matcher.matches?(lambda{|&block| non_yielding_subject(&block) })
          @matcher.failure_message_for_should.should == "expected to yield"
        end

        it "should provide a negative failure message for not yielding" do
          @matcher.matches?(lambda{|&block| non_yielding_subject(&block) })
          @matcher.failure_message_for_should_not.should == "expected not to yield"
        end

        it "should provide a failure message for having arguments" do
          @matcher.matches?(lambda{|&block| arg_yielding_subject(&block) })
          @matcher.failure_message_for_should.should == %q{expected to yield with (no args) but received it with ("ARG")}
        end
      end
      
      describe "with no args implied" do
        before(:each) { @matcher = YieldWith.new }
        
        it_should_behave_like "no arguments"
      end
      
      describe "with explicitly no_args" do
        before(:each) { @matcher = YieldWith.new(no_args()) }
        
        it_should_behave_like "no arguments"
      end

      describe "with an argument" do
        before(:each) do
          @matcher = YieldWith.new('ARG')
        end

        it "should not match if lambda yields with no args" do
          @matcher.matches?(lambda{|&block| no_arg_yielding_subject(&block) }).should be_false
        end

        it "should match if lambda yields with an argument" do
          @matcher.matches?(lambda{|&block| arg_yielding_subject(&block) }).should be_true
        end

        it "should provide a failure message for having no arguments" do
          @matcher.matches?(lambda{|&block| no_arg_yielding_subject(&block) })
          @matcher.failure_message_for_should.should == %q{expected to yield with ("ARG") but received it with (no args)}
        end

        it "should provide a negative failure message for having correct arguments" do
          @matcher.matches?(lambda{|&block| arg_yielding_subject(&block) })
          @matcher.failure_message_for_should_not.should == %q{expected not to yield with ("ARG")}
        end

        it "should provide a failure message for having wrong argument" do
          @matcher.matches?(lambda{|&block| other_arg_yielding_subject(&block) })
          @matcher.failure_message_for_should.should == %q{expected to yield with ("ARG") but received it with (561)}
        end
      end

      describe "with any arguments" do
        before(:each) do
          @matcher = YieldWith.new(any_args())
        end

        it "should match if lambda yields with no arguments" do
          @matcher.matches?(lambda{|&block| no_arg_yielding_subject(&block) }).should be_true
        end

        it "should match if lambda yields with an argument" do
          @matcher.matches?(lambda{|&block| arg_yielding_subject(&block) }).should be_true
        end
      end

      describe "with arguments checked by block" do
        describe "returning false" do
          before(:each) do
            @matcher = YieldWith.new(nil) { false }
          end

          it "should not match" do
            @matcher.matches?(lambda{|&block| arg_yielding_subject(&block) }).should be_false
          end
        end

        describe "returning true" do
          before(:each) do
            @matcher = YieldWith.new(nil) { true }
          end

          it "should match" do
            @matcher.matches?(lambda{|&block| arg_yielding_subject(&block) }).should be_true
          end
        end
      end
    end
  end
end

describe "should yield_with" do
  def yielder; yield; end
  it "should pass if yielded" do
    lambda {|&block| yielder(&block)}.should yield_with
  end
end