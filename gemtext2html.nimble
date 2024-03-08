# Package

version       = "0.1.0"
author        = "Azumabashi"
description   = "gemtext to html converter"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["gemtext2html"]


# Dependencies

requires "nim >= 2.0.0"
requires "parsegemini#50b10de"
