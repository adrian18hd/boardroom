{ LoggedOutRouter, request } =
  require '../support/controller_test_support'

describe 'UsersController', ->
  describe '#avatar', =>
    beforeEach =>
      @router = new LoggedOutRouter

    it "redirects to the url for the handle's avatar", (done) =>
      request(@router.app)
        .get("/user/avatar/#{encodeURIComponent '@handle'}")
        .end (request, response) ->
          expect(response.redirect).toBeTruthy()
          expect(response.headers.location).toMatch /api.twitter.com/
          done()
