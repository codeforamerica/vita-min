export default class IntercomBehavior {
  static openIfAskedFor() {
    if (window.location.hash.includes("open_intercom")) {
      window.Intercom('show');
    }
  }
}
