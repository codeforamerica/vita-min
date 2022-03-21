module Efile
  module DependentEligibility
    class Base
      attr_accessor :age, :dependent, :tax_year, :test_results, :except
      def initialize(dependent, tax_year, except: nil)
        @age = tax_year - dependent.birth_date.year
        @tax_year = tax_year
        @dependent = dependent
        @except = *except
        run_tests
      end

      # Keys with multiple conditions must be OR conditions, as only one must pass to remain eligible
      def self.rules
        raise "Child classes must implement rules"
      end

      def qualifies?
        disqualifiers.empty?
      end

      def disqualifiers
        test_results.reject { |_, value| value == true }.keys
      end

      def alive_during_tax_year?
        !dependent.born_after_tax_year?(tax_year)
      end

      private

      def run_tests
        @test_results ||= applied_rules.map do |rule, test|
          conditions = test.respond_to?(:each) ? test : [test]
          [rule, conditions.map { |qualifier| test(qualifier) }.any?(true)]
        end.to_h
      end

      # Looks for the qualifying method on dependent directly. If it can't find it, looks for rule inside this class.
      def test(qualifier)
        respond_to?(qualifier, true) ? send(qualifier) : dependent.send(qualifier)
      end

      def applied_rules
        except.present? ? self.class.rules.reject { |k, _| except.include?(k) } : self.class.rules
      end
    end
  end
end