To add a new "component" to the Hub:

- Create erb.html as hub/components/*.html.erb
- Give it a HTML attribute e.g. data-component="MyComponent"
- Make a JS file with e.g. `export default MyComponent` in app/javascript/hub/MyComponent.js
- Import and run the component in `hub.js.erb`, there should be an example there already you can copy
