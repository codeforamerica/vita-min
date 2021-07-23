require "rails_helper"

RSpec.describe DependentAwareSeek do
  let(:navigation_class) do
    Class.new do
      include ControllerNavigation
      include DependentAwareSeek
    end
  end

  context "when there is no current intake" do
    before do
      stub_const("BaseController",
                 Class.new do
                   def self.show?(_, _)
                     true
                   end

                   def params; {}; end

                   def visitor_record; end
                 end
      )

      stub_const("FirstController", Class.new(BaseController))
      stub_const("SecondController", Class.new(BaseController))
      stub_const("ThirdController", Class.new(BaseController))
      stub_const("#{navigation_class.name}::FLOW",
                 [
                   FirstController,
                   SecondController,
                   ThirdController,
                 ]
      )
    end

    describe "#next" do
      context "when current controller is second to last or before" do
        before do
          allow(SecondController).to receive(:show?) { false }
        end

        it "returns numeric index for next non-skipped controller in main flow" do
          navigation = navigation_class.new(FirstController.new)
          expect(navigation.next).to eq(ThirdController)
        end
      end
    end

    describe "#prev" do
      before do
        allow(SecondController).to receive(:show?) { false }
      end

      it "returns path for next non-skipped controller in main flow" do
        navigation = navigation_class.new(ThirdController.new)
        expect(navigation.prev).to eq(FirstController)
      end
    end
  end

  context "when there is a current intake" do
    before do
      stub_const("BaseController",
                 Class.new do
                   def self.show?(_, _)
                     true
                   end

                   def params; {}; end

                   def visitor_record; FactoryBot.create(:ctc_intake); end
                 end
      )

      stub_const("FirstController", Class.new(BaseController))
      stub_const("SecondController", Class.new(BaseController))
      stub_const("ThirdController", Class.new(BaseController))
      stub_const("#{navigation_class.name}::FLOW",
                 [
                   FirstController,
                   SecondController,
                   ThirdController,
                 ]
      )
    end

    describe "#next" do
      context "when current controller is second to last or before" do
        before do
          allow(SecondController).to receive(:show?) { false }
        end

        it "returns numeric index for next non-skipped controller in main flow" do
          navigation = navigation_class.new(FirstController.new)
          expect(navigation.next).to eq(ThirdController)
        end
      end

      context "when current controller is the last" do
        it "returns nil" do
          navigation = navigation_class.new(ThirdController.new)
          expect(navigation.next).to be_nil
        end
      end
    end

    describe "#prev" do
      before do
        allow(SecondController).to receive(:show?) { false }
      end

      it "returns path for next non-skipped controller in main flow" do
        navigation = navigation_class.new(ThirdController.new)
        expect(navigation.prev).to eq(FirstController)
      end

      context "when current controller is the first" do
        it "returns nil" do
          navigation = navigation_class.new(FirstController.new)
          expect(navigation.prev).to be_nil
        end
      end
    end

    context "with dependents" do
      before do
        stub_const("BaseController",
                   Class.new do
                     def self.show?(_, dependent)
                       dependent.present?
                     end

                     def params; { id: CanonicalIntake.dependents.last.id }; end

                     def visitor_record; CanonicalIntake ; end
                   end
        )
        stub_const("CanonicalIntake", FactoryBot.create(:ctc_intake, :with_dependents))
        stub_const("FirstController", Class.new(BaseController))
        stub_const("SecondController", Class.new(BaseController))
        stub_const("ThirdController", Class.new(BaseController))
        stub_const("#{navigation_class.name}::FLOW",
                   [
                     FirstController,
                     SecondController,
                     ThirdController,
                   ]
        )
      end

      describe "#next" do
        context "when current controller is second to last or before" do
          before do
            allow(SecondController).to receive(:show?) { false }
          end

          it "returns numeric index for next non-skipped controller in main flow" do
            navigation = navigation_class.new(FirstController.new)
            expect(navigation.next).to eq(ThirdController)
          end
        end

        context "when current controller is the last" do
          it "returns nil" do
            navigation = navigation_class.new(ThirdController.new)
            expect(navigation.next).to be_nil
          end
        end
      end

      describe "#prev" do
        before do
          allow(SecondController).to receive(:show?) { false }
        end

        it "returns path for next non-skipped controller in main flow" do
          navigation = navigation_class.new(ThirdController.new)
          expect(navigation.prev).to eq(FirstController)
        end

        context "when current controller is the first" do
          it "returns nil" do
            navigation = navigation_class.new(FirstController.new)
            expect(navigation.prev).to be_nil
          end
        end
      end
    end
  end
end
