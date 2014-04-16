class boardroom.models.UserIdentity extends Backbone.Model
  @avatar: (handle) ->
    "/user/avatar/#{encodeURIComponent handle}"

  userId: () => @get 'userId'
  avatar: () =>
    avatar = @get 'avatar'
    avatar.replace /\w+\.twimg\.com/, 'pbs.twimg.com' # twitter changed it's img urls
  displayName: () => @get 'displayName'
