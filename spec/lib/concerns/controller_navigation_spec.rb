require "rails_helper"

RSpec.describe ControllerNavigation do
  class ConcernedWithControllerNavigation
    include ControllerNavigation
  end
  let(:navigation_class) { ConcernedWithControllerNavigation }
  before do
    class BaseController
      def self.show?(_)
        true
      end

      def self.model_for_show_check(controller)
        controller.visitor_record
      end

      def visitor_record; end

      def params
        {}
      end

      def review_controller; end
    end

    class FirstController < BaseController; end
    class SecondController < BaseController; end
    class ThirdController < BaseController; end
    class FourthController < BaseController; end

    class ReviewController < BaseController; end

    stub_const("#{navigation_class.name}::FLOW",
               [
                   FirstController,
                   SecondController,
                   ThirdController,
               ]
    )
  end

  describe ".controllers" do
    it "returns the main flow's controllers" do
      expect(navigation_class.controllers).to match_array(
                                                  [
                                                      FirstController,
                                                      SecondController,
                                                      ThirdController,
                                                  ]
                                              )
    end
  end

  describe ".pages" do
    it "returns the main flow" do
      expect(navigation_class.pages(nil)).to match_array(
                                                [
                                                  { controller: FirstController },
                                                  { controller: SecondController },
                                                  { controller: ThirdController},
                                                ]
                                              )
    end
  end

  describe ".first" do
    it "delegates to .controllers" do
      expect(navigation_class.first).to eq(FirstController)
    end
  end

  describe "#next" do
    context "when current controller is second to last or before" do
      before do
        allow(SecondController).to receive(:show?) { false }
      end

      it "returns numeric index for next non-skipped controller in main flow" do
        navigation = navigation_class.new(FirstController.new)
        expect(navigation.next).to eq({ controller: ThirdController })
      end
    end

    context "when current controller is the last" do
      it "returns nil" do
        navigation = navigation_class.new(ThirdController.new)
        expect(navigation.next).to be_nil
      end
    end

    context "when constructed with an item index" do
      let(:pages) {
        [
          { controller: FirstController },
          { controller: SecondController },
          { controller: ThirdController, item_index: 0 },
          { controller: FourthController, item_index: 0 },
          { controller: ThirdController, item_index: 1 },
          { controller: FourthController, item_index: 1 }
        ]
      }
      before do
        allow(navigation_class).to receive(:pages).and_return(pages)
      end

      it "returns the correct next page" do
        navigation = navigation_class.new(ThirdController.new, item_index: 1)
        expect(navigation.next).to eq({ controller: FourthController, item_index: 1 })
      end
    end

    context "when return to review params" do
      before do
        allow_any_instance_of(BaseController).to receive(:review_controller).and_return(ReviewController)
      end

      context "is return_to_review=y" do
        before do
          allow_any_instance_of(SecondController).to receive(:params).and_return({ return_to_review: "y"})
        end

        it "returns path for review controller" do
          navigation = navigation_class.new(SecondController.new)
          expect(navigation.next).to eq({ controller: ReviewController })
        end
      end

      context "has return_to_review_after=controller_name" do
        before do
          allow_any_instance_of(FirstController).to receive(:params).and_return({ return_to_review_after: "first_controller"})
          allow_any_instance_of(SecondController).to receive(:params).and_return({ return_to_review_after: "third_controller"})
          allow_any_instance_of(ThirdController).to receive(:params).and_return({ return_to_review_after: "third_controller"})
        end

        it "returns review controller if we are proceeding past the specified controller" do
          navigation = navigation_class.new(FirstController.new)
          expect(navigation.next).to eq({ controller: ReviewController })
        end

        it "returns next controller in flow if we haven't proceeded far enough to return to review yet, and preserves params" do
          navigation = navigation_class.new(SecondController.new)
          expect(navigation.next).to eq({ controller: ThirdController, params: { return_to_review_after: "third_controller"} })
        end

        it "returns review controller if we are proceeding past the specified controller, even if it's the last in the flow" do
          navigation = navigation_class.new(ThirdController.new)
          expect(navigation.next).to eq({ controller: ReviewController })
        end
      end

      context "has return_to_review_after=step_name" do
        let(:pages) {
          [
            { controller: FirstController },
            { controller: SecondController },
            { controller: ThirdController, item_index: 0, step: "repeated_step" },
            { controller: FourthController, item_index: 0, step: "repeated_step" },
            { controller: ThirdController, item_index: 1, step: "repeated_step" },
            { controller: FourthController, item_index: 1, step: "repeated_step" }
          ]
        }
        before do
          allow(navigation_class).to receive(:pages).and_return(pages)
        end

        context "without an item index" do
          before do
            allow_any_instance_of(BaseController).to receive(:params).and_return({ return_to_review_after: "repeated_step"})
          end

          it "returns the next page and preserves params when not done with all iterations of the named step" do
            navigation = navigation_class.new(FourthController.new, item_index: 0)
            expect(navigation.next).to eq({ controller: ThirdController, item_index: 1, step: "repeated_step", params: { return_to_review_after: "repeated_step"} })

            navigation = navigation_class.new(ThirdController.new, item_index: 1)
            expect(navigation.next).to eq({ controller: FourthController, item_index: 1, step: "repeated_step", params: { return_to_review_after: "repeated_step"} })
          end

          it "returns the review controller when done with all iterations of the named step" do
            navigation = navigation_class.new(FourthController.new, item_index: 1)
            expect(navigation.next).to eq({ controller: ReviewController })
          end
        end

        context "with an item index" do
          before do
            allow_any_instance_of(BaseController).to receive(:params).and_return({ return_to_review_after: "repeated_step_0"})
          end

          it "returns the next page and preserves params when not done with the specified iterations of the named step" do
            navigation = navigation_class.new(SecondController.new)
            expect(navigation.next).to eq({ controller: ThirdController, item_index: 0, step: "repeated_step", params: { return_to_review_after: "repeated_step_0"} })

            navigation = navigation_class.new(ThirdController.new, item_index: 0)
            expect(navigation.next).to eq({ controller: FourthController, item_index: 0, step: "repeated_step", params: { return_to_review_after: "repeated_step_0"} })
          end

          it "returns the review controller when done with the specified iterations of the named step when it isn't the last step" do
            navigation = navigation_class.new(FourthController.new, item_index: 0)
            expect(navigation.next).to eq({ controller: ReviewController })
          end

          context "when the specified iteration of the named step is at the end of the flow" do
            before do
              allow_any_instance_of(BaseController).to receive(:params).and_return({ return_to_review_after: "repeated_step_1"})
            end

            it "returns the review controller when done with the specified iterations of the named step, even if it's the last step" do
              navigation = navigation_class.new(FourthController.new, item_index: 1)
              expect(navigation.next).to eq({ controller: ReviewController })
            end
          end
        end
      end
    end
  end

  describe "#prev" do
    before do
      allow(SecondController).to receive(:show?) { false }
    end

    it "returns path for prev non-skipped controller in main flow" do
      navigation = navigation_class.new(ThirdController.new)
      expect(navigation.prev).to eq({ controller: FirstController })
    end

    context "when current controller is the first" do
      it "returns nil" do
        navigation = navigation_class.new(FirstController.new)
        expect(navigation.prev).to be_nil
      end
    end

    context "when constructed with an item index" do
      let(:pages) {
        [
          { controller: FirstController },
          { controller: SecondController },
          { controller: ThirdController, item_index: 0 },
          { controller: FourthController, item_index: 0 },
          { controller: ThirdController, item_index: 1 },
          { controller: FourthController, item_index: 1 }
        ]
      }
      before do
        allow(navigation_class).to receive(:pages).and_return(pages)
      end

      it "returns the correct next page" do
        navigation = navigation_class.new(ThirdController.new, item_index: 1)
        expect(navigation.prev).to eq({ controller: FourthController, item_index: 0 })
      end
    end

    context "when return to review params" do
      before do
        allow_any_instance_of(BaseController).to receive(:review_controller).and_return(ReviewController)
      end

      context "is return_to_review=y" do
        before do
          allow_any_instance_of(SecondController).to receive(:params).and_return({ return_to_review: "y"})
        end

        it "returns path for review controller" do
          navigation = navigation_class.new(SecondController.new)
          expect(navigation.prev).to eq({ controller: ReviewController })
        end
      end

      context "has return_to_review_before=controller_name" do
        before do
          allow(SecondController).to receive(:show?).and_return(true)
          allow_any_instance_of(FirstController).to receive(:params).and_return({ return_to_review_before: "first_controller"})
          allow_any_instance_of(SecondController).to receive(:params).and_return({ return_to_review_before: "second_controller"})
          allow_any_instance_of(ThirdController).to receive(:params).and_return({ return_to_review_before: "second_controller"})
        end

        it "returns review controller if we are proceeding past the specified controller" do
          navigation = navigation_class.new(SecondController.new)
          expect(navigation.prev).to eq({ controller: ReviewController })
        end

        it "returns previous controller in flow if we haven't proceeded far enough to return to review yet, and preserves params" do
          navigation = navigation_class.new(ThirdController.new)
          expect(navigation.prev).to eq({ controller: SecondController, params: { return_to_review_before: "second_controller"} })
        end

        it "returns review controller if we are proceeding past the specified controller, even if it's the first in the flow" do
          navigation = navigation_class.new(FirstController.new)
          expect(navigation.prev).to eq({ controller: ReviewController })
        end
      end

      context "has return_to_review_before=step_name" do
        let(:pages) {
          [
            { controller: FirstController },
            { controller: SecondController },
            { controller: ThirdController, item_index: 0, step: "repeated_step" },
            { controller: FourthController, item_index: 0, step: "repeated_step" },
            { controller: ThirdController, item_index: 1, step: "repeated_step" },
            { controller: FourthController, item_index: 1, step: "repeated_step" }
          ]
        }
        before do
          allow(navigation_class).to receive(:pages).and_return(pages)
        end

        context "without an item index" do
          before do
            allow_any_instance_of(BaseController).to receive(:params).and_return({ return_to_review_before: "repeated_step"})
          end

          it "returns the prev page and preserves params when not done with all iterations of the named step" do
            navigation = navigation_class.new(FourthController.new, item_index: 1)
            expect(navigation.prev).to eq({ controller: ThirdController, item_index: 1, step: "repeated_step", params: { return_to_review_before: "repeated_step"} })

            navigation = navigation_class.new(FourthController.new, item_index: 0)
            expect(navigation.prev).to eq({ controller: ThirdController, item_index: 0, step: "repeated_step", params: { return_to_review_before: "repeated_step"} })
          end

          it "returns the review controller when done with all iterations of the named step" do
            navigation = navigation_class.new(ThirdController.new, item_index: 0)
            expect(navigation.prev).to eq({ controller: ReviewController })
          end

          context "even if there's nothing before the named step in the flow" do
            let(:pages) {
              [
                { controller: ThirdController, item_index: 0, step: "repeated_step" },
                { controller: FourthController, item_index: 0, step: "repeated_step" },
                { controller: ThirdController, item_index: 1, step: "repeated_step" },
                { controller: FourthController, item_index: 1, step: "repeated_step" },
                { controller: FirstController },
                { controller: SecondController }
              ]
            }

            it "returns the review controller when done with all iterations of the named step" do
              navigation = navigation_class.new(ThirdController.new, item_index: 0)
              expect(navigation.prev).to eq({ controller: ReviewController })
            end
          end
        end

        context "with an item index" do
          let(:pages) {
            [
              { controller: ThirdController, item_index: 0, step: "repeated_step" },
              { controller: FourthController, item_index: 0, step: "repeated_step" },
              { controller: ThirdController, item_index: 1, step: "repeated_step" },
              { controller: FourthController, item_index: 1, step: "repeated_step" },
              { controller: FirstController },
              { controller: SecondController }
            ]
          }

          before do
            allow_any_instance_of(BaseController).to receive(:params).and_return({ return_to_review_before: "repeated_step_1"})
          end

          it "returns the prev page and preserves params when not done with the specified iterations of the named step" do
            navigation = navigation_class.new(FourthController.new, item_index: 1)
            expect(navigation.prev).to eq({ controller: ThirdController, item_index: 1, step: "repeated_step", params: { return_to_review_before: "repeated_step_1"} })

            navigation = navigation_class.new(FirstController.new)
            expect(navigation.prev).to eq({ controller: FourthController, item_index: 1, step: "repeated_step", params: { return_to_review_before: "repeated_step_1"} })
          end

          it "returns the review controller when done with the specified iterations of the named step when it isn't the first step" do
            navigation = navigation_class.new(ThirdController.new, item_index: 1)
            expect(navigation.prev).to eq({ controller: ReviewController })
          end

          context "when the specified iteration of the named step is at the beginning of the flow" do
            before do
              allow_any_instance_of(BaseController).to receive(:params).and_return({ return_to_review_before: "repeated_step_0"})
            end

            it "returns the review controller when done with the specified iterations of the named step, even if it's the first step" do
              navigation = navigation_class.new(ThirdController.new, item_index: 0)
              expect(navigation.prev).to eq({ controller: ReviewController })
            end
          end
        end
      end
    end

  end
end
