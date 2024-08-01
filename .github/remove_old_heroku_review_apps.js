#!/usr/bin/env node

const execSync = require('child_process').execSync;

let apps = execSync("heroku apps:list --team getyourrefund").toString()
let prs = JSON.parse(execSync("gh pr list --json number")).map(function (line) { return line.number })

function removeReviewApp(number) {
   let app_name = `gyr-review-app-${number}`
   console.log(`Gonna delete ${app_name}`)
   execSync(`heroku run rails heroku:review_app_predestroy --app=${ app_name }`)
   execSync(`heroku apps:destroy --app=${ app_name } --confirm=${ app_name }`)
}

apps.split("\n").forEach(function (app) {
   let match = app.match(/gyr-review-app-(\d+)/)
   if (!match) {
      return
   }
   let number = parseInt(match[1], 10)
   if (!prs.includes(number)) {
      removeReviewApp(number)
   }
});
