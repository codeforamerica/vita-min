import IntercomBehavior from "lib/intercom_behavior";

describe('IntercomBehavior', () => {
  beforeEach(() => {
    window.Intercom = jest.fn();
  });

  describe('openIfAskedFor', () => {
    describe('when asked for', () => {
      beforeEach(() => {
        delete window.location

        window.location = {
          hash: '#open_intercom',
        }
      })
      test('it opens', () => {
        IntercomBehavior.openIfAskedFor();
        expect(window.Intercom).toHaveBeenCalledWith('show');
      });
    });

    describe('when not asked for', () => {
      beforeEach(() => {
        delete window.location

        window.location = {
          hash: '#',
        }
      })
      test('it does not open', () => {
        IntercomBehavior.openIfAskedFor();
        expect(window.Intercom).not.toHaveBeenCalled();
      });
    });
  });
});
