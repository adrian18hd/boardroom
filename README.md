# [Board Room](http://boardroom.carbonfive.com/)

Interactive story boarding for distributed teams.

Currently we use Board Room for reflection meetings, but it will soon be useful for:
* Story writing
* Story mapping
* General distributed story boarding

Board Room is built with [Node.js](http://nodejs.org/), [MongoDB](http://www.mongodb.org/), and [Socket.IO](http://socket.io/).

## Development

Product Owners:
- Mike Wynholds
- Christian Nelson (if Mike's unavailable)

[Project (Pivotal Tracker)](https://www.pivotaltracker.com/projects/540409)
[![Analytics](https://ga-beacon.appspot.com/UA-620051-20/boardroom/README?pixel)]()

### Git Branching Strategy

#### Overview
- Develop on feature branches (named like `features/32195787-delete-a-board`)
- `merge --no-ff` into `development`, and deliver in Tracker
- Once accepted, merge into `master`

### Environment Hosting
- [Acceptance](http://boardroom.carbonfive.com:81/)
- [Production](http://boardroom.carbonfive.com/)

### Testing

- [jasmine-headless-webkit](http://johnbintz.github.com/jasmine-headless-webkit/) (clientside testing)
- [jasmine-node](https://github.com/mhevery/jasmine-node) (serverside
testing) use "--coffee" to enable CoffeeScript support
- [Sinon.JS](http://sinonjs.org/) (spies, faking time)
- Cakefile: "cake spec:client", "cake spec:server", "cake spec"
- npm: "npm test" is also available for running all tests

### Deploying

Deployment uses Capistrano. Acceptance is the default stage.

- cap deploy
- cap production deploy

## Install

### OS X

#### Quick

    brew update
    brew install mongodb
    brew install redis
    brew install node
    npm install
    # start mongo. for instructions: brew info mongodb
    # start redis. for instructions: brew info redis
    # setup ENV variables (see below)
    node ./index.js

Visit [localhost:7777](http://localhost:7777).

#### With Details

1. Make sure you have the latest [Homebrew](http://mxcl.github.com/homebrew/) and formulae:
   `brew update`
2. Install [MongoDB](http://www.mongodb.org/) with Homebrew:
   `brew install mongodb`
3. Follow homebrew's instructions to run Mongo. They're printed after installation; view them again with `brew info mongodb`.
4. Install [Redis](http://redis.io/) with Homebrew:
   `brew install redis`
5. Follow homebrew's instructions to run Redis. They're printed after installation; view them again with `brew info redis`.
6. Install [Node.js](http://nodejs.org/) with Homebrew:
   `brew install node`
7. Install project dependencies using npm:
   `npm install`
8. Add the [required environment variables](#required-environment-variables) to your shell config (ex: `~/.bashrc`)
9. Run Boardroom:
   `node ./index.js`
10. Visit [localhost:7777](http://localhost:7777).

#### Required Environment Variables
To support the various OAuth schemes, add the matching client keys to the
following environment variables:

    export TWITTER_SECRET='<your Twitter secret>'
    export GOOGLE_CLIENT_SECRET='<your Google client secret>'
    export FACEBOOK_APP_SECRET='<your Facebook app secret>'

### Ubuntu / Debian

		$ sudo apt-get install mongodb-10gen nodejs nodejs-dev npm redis-server
		$ sudo npm install

## Load Testing

You can generate load to a Boardroom server with the 'load' tool:

    script/load

## New to Mongo?

Run through the quick tutorial in the "Try It Out" shell at [mongodb.org](http://www.mongodb.org/).

Then:

    $ mongo
    MongoDB shell version: 2.0.4
    connecting to: test
    > help
    ⋮
    > show dbs
    boardroom_development
    ⋮
    > use boardroom_development
    switched to db boardroom_development
    > db.boards.find()
    { "name" : "test", "title" : "test", "_id" : ObjectId("4ff1e6658aa3445a14000001") }
    > db.cards.find()
    ⋮
