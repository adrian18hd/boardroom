class boardroom.views.Card extends boardroom.views.Base
  className: 'card'
  template: _.template """
    <div class='header-bar'>
      <span class='delete-btn'>&times;</span>
      <span class='notice'></span>
      <div class='plus-authors'></div>
    </div>
    <textarea><%= text %></textarea>
    <div class='footer'>
      <div class='plus-count'></div>
      <div class='toolbar'>
        <div class='plus1'>
          <a class='btn' href='#'>+1</a>
        </div>
        <div class='colors'>
          <span class='color color-0'></span>
          <span class='color color-1'></span>
          <span class='color color-2'></span>
          <span class='color color-3'></span>
          <span class='color color-4'></span>
        </div>
        <div class='authors'></div>
      </div>
    </div>
  """

  attributes: ->
    id: @model.id

  events: # human interaction event
    'click .color'     : 'hiChangeColor'
    'keyup textarea'   : 'hiChangeText'
    'click textarea'   : 'hiFocusText'
    'click .plus1 .btn': 'hiIncrementPlusCount'
    'click .delete-btn': 'hiDelete'

  initialize: (attributes) ->
    super attributes
    @initializeDraggable()
    @model.on 'change:colorIndex',  @updateColor, @
    @model.on 'change:text',        @updateText, @
    @model.on 'change:x',           @updateX, @
    @model.on 'change:y',           @updateY, @
    @model.on 'change:plusAuthors', @updatePlusAuthors, @
    @model.on 'change:authors',     @updateAuthors, @

  onLockPoll: ()=>
    @enableEditing 'textarea'

  initializeDraggable: ->
    @$el.draggable
    #minX: @boardView.left() + 12
    #minY: @boardView.top()  + 12
      isTarget: (target) =>
        # return false if $(target).is 'input'
        # return false if $(target).is '.color'
        return false if $(target).is '.delete'
        true
      isOkToDrag: () =>
        # dont allow card to drag if its the only one in its group (allow the group to drag)
        @model.group().cards().length > 1
      onMouseDown: =>
        @model.group().bringForward()
        #@rememberRestingSpot()
      onMouseMove: =>
        @model.moveTo @left(), @top()
      onMouseUp: =>
        #nothingToDropOnto = => @moveBackToRestingSpot() if (@$el? and @$el.is(':visible'))
        #setTimeout nothingToDropOnto, 350 # move back if nothing picks up the drop
      startedDragging:()=>
        @$el.addClass('dragging')
      stoppedDragging: ()=>
        @$el.removeClass('dragging')

  ###
      render
  ###

  render: ->
    @$el.html(@template(@model.toJSON()))
    @updatePosition @model.get('x'), @model.get('y')
    @updateColor @model, @model.get('colorIndex')
    @updateAuthors @model, @model.get('authors')
    @updatePlusAuthors @model, @model.get('plusAuthors')
    @

  updateColor: (card, color, options) ->
    @$el.removeClassMatching /color-\d+/g
    @$el.addClass "color-#{color ? 2}"

  updateText: (card, text, options) =>
    @$el.find('textarea').val(text)
    if options?.rebroadcast
      @showNotice user: @model.get('author'), message: "#{@model.get('author')} is typing..."
      @authorLock.lock 500

  updateX: (card, x, options) =>
    @updatePosition x, card.get('y'), options

  updateY: (card, y, options) =>
    @updatePosition card.get('x'), y, options

  updatePosition: (x, y, options) =>
    @moveTo x: x, y: y
    if options?.rebroadcast
      @showNotice user: @model.get('author'), message: @model.get('author')
      @authorLock.lock 500

  updatePlusAuthors: (card, plusAuthors, options) =>
    return if plusAuthors.length == 0

    $plusCount = @$('.plus-count')
    $plusCount.text "+#{plusAuthors.length}"
    $plusCount.attr 'title', _.map(plusAuthors, (author) -> _.escape(author)).join(', ')

    $plusAuthors = @$('.plus-authors')
    $plusAuthors.empty()
    for plusAuthor in plusAuthors
      avatar = boardroom.models.User.avatar plusAuthor
      $plusAuthors.append("<img class='avatar' src='#{avatar}' title='#{_.escape plusAuthor}'/>")

    if plusAuthors.indexOf(@model.currentUser()) > -1
        @$('.plus1 .btn').remove()

  updateAuthors: (card, authors, options) =>
    return if authors.length == 0

    $authors = @$('.authors')
    $authors.empty()
    for author in authors
      avatar = boardroom.models.User.avatar author
      $authors.append("<img class='avatar' src='#{avatar}' title='#{_.escape author}'/>")

  adjustTextarea: ->
    $textarea = @$ 'textarea'
    $textarea.autosize()
    @analyzeText $textarea

  analyzeText: ($textarea) ->
    $card = $textarea.parents '.card'
    $card.removeClass 'i-wish i-like'
    if matches = $textarea.val().match /^i (like|wish)/i
      $card.addClass("i-#{matches[1]}")

  focus: ->
    @$el.find('textarea').focus()

  ###
      human interaction event handlers
  ###

  hiDelete: (event) ->
    @model.delete()

  hiChangeColor: (event) ->
    colorIndex = $(event.target).attr('class').match(/color-(\d+)/)[1]
    @model.colorize colorIndex

  hiChangeText: (e)->
    @model.type @$('textarea').val()

  hiFocusText: (event)->
    @model.focus()

  hiIncrementPlusCount: (e) ->
    @model.plusOne()
