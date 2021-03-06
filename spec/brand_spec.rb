require "test_helper"
require "credit_card_detector/brand"

module CreditCardDetector
  describe Brand do
    describe "#matches?" do
      let(:data) { { name: "Visa", rules: rules, options: {} } }
      let(:brand) { Brand.new(:visa, data) }

      describe "when brand doesn't have any rules" do
        let(:rules) { [] }
        it "doesn't matches any number" do
          assert_equal brand.matches?("1234"), false
          assert_equal brand.matches?(""), false
          assert_equal brand.matches?("4012888888881881"), false
        end
      end

      describe "when brand has a single rule" do
        let(:rules) {
          [ { length: [16, 13], prefixes: ['4'] } ]
        }

        it "matches valid numbers" do
          numbers = VALID_NUMBERS.fetch(:visa)
          numbers.each do |number|
            assert_equal brand.matches?(number.tr("- ", "")), true
          end
        end

        it "doesn't match invalid numbers" do
          assert_equal brand.matches?("42222222222221"), false
        end
      end

      describe "when brand has multiple rules" do
        let(:rules) {
          [
            { length: [15, 16], prefixes: ['357', '356', '353'] },
            { length: [15], prefixes: ['1800'] },
            { length: [19], prefixes: ['357266'] }
          ]
        }

        it "matches valid numbers" do
          numbers = VALID_NUMBERS.fetch(:jcb)
          numbers.each do |number|
            assert_equal brand.matches?(number.tr("- ", "")), true
          end
        end

        it "doesn't match invalid numbers" do
          assert_equal brand.matches?("1800016382773921"), false
        end
      end
    end

    describe "#luhn?" do
      it "returns true when NO skip_luhn option is set on brand" do
        brand = Brand.new(:maestro, name: "maestro", options: {}, rules: [])
        assert_equal brand.luhn?, true
      end

      it "returns false when skip_luhn option is set on brand" do
        brand = Brand.new(:maestro, name: "rupay", options: { skip_luhn: true }, rules: [])
        assert_equal brand.luhn?, false
      end
    end
  end
end
