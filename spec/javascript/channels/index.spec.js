const sayHello = require('channels/index')

test("we can say hello", function (){
  expect(sayHello()).toBe("hello!")
});