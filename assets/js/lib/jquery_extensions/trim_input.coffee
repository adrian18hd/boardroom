$.fn.textMetrics = () ->
  if $(@).is 'input' or $(@).is 'textarea'
    html = $(@).val()
    html = $(@).attr('placeholder') if html == ''
  else
    html = $(@).html()
  html ?= ''
  $div = $("<div>#{html}</div>").
    css({ position: 'absolute', left: -1000, top: -1000, display: 'none' }).
    appendTo($('body'))
  styles = [ 'font-size', 'font-style', 'font-weight', 'font-family', 'line-height', 'text-transform', 'letter-spacing' ]
  $div.css style, $(@).css(style) for style in styles
  metrics = { height: $div.outerHeight(), width: $div.outerWidth() }
  $div.remove()
  metrics

$.fn.trimInput = (minWidth, maxWidth) ->
  @each ->
    unless maxWidth
      curWidth = parseInt $(@).css('width')
      $(@).css 'width', 'inherit'
      maxWidth = $(@).width()
      $(@).css 'width', curWidth

    setWidth = =>
      width = $(@).textMetrics().width + 3
      width = Math.max width, 20
      width = Math.min width, maxWidth
      $(@).css 'width', width

    setWidth() if not $(@).is(':focus')

    $(@).blur setWidth

    $(@).focus =>
      $(@).css 'width', maxWidth
