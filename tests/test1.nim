import unittest
import strutils

import gemtext2html

const expected = """
<html>
<body>
<h1>This is text</h1>
<h2>subtext</h2>
<p>Hello!</p>
<p>
<a href="https://example.com">https://example.com</a><br>
<a href="https://example.com">example</a>
</p>
<p>
another<br>text
</p>
<p>new paragraph</p>

<h2>another subtext</h2>
<h3>subsubtext</h3>
<p>aaa</p>

<h2>yet another subtext</h2>
<p>bbb</p>
<figure>
<pre>f x y = x + y</pre>
<figcaption>foo</figcaption>
</figure>
<figure>
<pre>g x = x * x</pre>
</figure>
<p>End!</p>
</body>
</html>
"""


test "check conversion is executed correctly":
  const gemtext = """
# This is text
## subtext
Hello!
=> https://example.com
=> https://example.com example

another
text

new paragraph

## another subtext
### subsubtext
aaa
## yet another subtext
bbb
```foo
f x y = x + y
```
```
g x = x * x
```

End!
"""
  check gemtext.convert.replace("\n", "") == expected.replace("\n", "")

test "check conversion is executed correctly from file":
  check convertFromFile("tests/test1.gmi").replace("\n", "") == expected.replace("\n", "")
