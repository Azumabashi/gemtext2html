import parsegemini
import streams
import htmlgen
import strutils
import os
import options

proc convert*(gemtext: string): string =
  ## Convert `gemtext` to HTML format and return it.
  var content: seq[string]
  var nextParagraph: seq[string]
  var parser: GeminiParser
  var status: GeminiLineEvent

  proc clearNextParagraphContent(joinKey: string = "<br>"): Option[string] =
    ## Join `nextParagraph` using `joinKey` and flush it.
    if nextParagraph.len == 0:
      return none(string)
    let flushed = nextParagraph.join(joinKey)
    nextParagraph = @[]
    return some(flushed)

  proc appendNextTag() =
    ## Generate HTML description using `nextParagraph` and `status` (which describes how the elements of `nextParagraph` should be treated as) and push it to `content`.
    ## The elements of `nextParagraph` are wrapped with proper HTML tag.
    if parser.kind == status:
      if status != gmiText and status != gmiVerbatimMarker:
        # if reading same parts, discard
        return
      elif parser.text.len > 0:
        # if reading nonempty `gmiText` lines, discard
        return
    elif parser.kind == gmiVerbatim and status == gmiVerbatimMarker:
      # this is the case of beginning of reading preformatted text
      # there are nothing to do here, so discarded
      return
    
    case status
    of gmiEof, gmiHeader1, gmiHeader2, gmiHeader3:
      # cannot reach here
      discard
    of gmiText, gmiLink:
      # wrap with `p` tag
      let nextContent = clearNextParagraphContent()
      if nextContent.isSome():
        content.add(p(nextContent.get()))
    of gmiVerbatimMarker:
      # the alt text is wrapped with `figcaption` if it exists.
      # all of the verbatim text is wrapped with `figure`.
      if parser.kind == gmiVerbatim:
        nextParagraph.add(parser.text)
        return
      else:
        let header = nextParagraph[0]
        let text = pre(nextParagraph[1..<nextParagraph.len].join("\n"))
        let figureTagContent = if header.len > 0: text & figcaption(header) else: text
        content.add(figure(figureTagContent))
        nextParagraph = @[]
    of gmiVerbatim:
      # there are nothing to do with here
      discard
    of gmiListItem:
      # wrap with `ul`
      let nextContent = clearNextParagraphContent(joinKey="\n")
      if nextContent.isSome():
        content.add(ul(nextContent.get()))
    of gmiQuote:
      # wrap with `blockquote`
      let nextContent = clearNextParagraphContent()
      if nextContent.isSome():
        content.add(blockquote(nextContent.get()))

  open(parser, newStringStream(gemtext))
  nextParagraph = @[]

  # iterate everything
  while true:
    parser.next()
    case parser.kind
    of gmiEof:
      # append the last parts
      appendNextTag()
      break
    of gmiLink:
      # wrap with `a` tag here
      # if link text does not exist, use `uri`
      appendNextTag()
      let ptext = $parser.text
      let uri = $parser.uri
      let text = if ptext.len > 0: ptext else: uri
      nextParagraph.add(a(href = uri, text))
    of gmiText:
      # blank line corresponds to new paragraph
      appendNextTag()
      if ($(parser.text)).len > 0:
        # otherwise push text to `nextParagraph`
        nextParagraph.add(parser.text)
    # headers
    of gmiHeader1:
      appendNextTag()
      content.add(h1($parser.text))
    of gmiHeader2:
      appendNextTag()
      content.add(h2($parser.text))
    of gmiHeader3:
      appendNextTag()
      content.add(h3($parser.text))
    # other parts
    of gmiVerbatimMarker, gmiVerbatim, gmiQuote:
      appendNextTag()
      nextParagraph.add($parser.text)
    of gmiListItem:
      appendNextTag()
      nextParagraph.add(li($parser.text))
    
    status = parser.kind

  close(parser)
  
  # wrap with `html` and `body`
  return html(body(content.join("\n")))

proc convertFromFile*(path: string): string {.raises: [OSError, IOError].} =
  path.readFile.convert

when isMainModule:
  if paramCount() == 0:
    echo "Specify gemtext path."
    quit(1)
  echo commandLineParams()[0].convertFromFile
