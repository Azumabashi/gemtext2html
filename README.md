# gemtext2html
This program converts [gemtext](https://geminiprotocol.net/docs/cheatsheet.gmi) to HTML.
For an example, see test program.

## Usage
As a binary file:
```
$ git clone https://github.com/Azumabashi/gemtext2html
$ cd gemtext2html
$ nimble build
$ ./gemtext2html path/to/sample.gmi
```

As a library, install with:
```
$ nimble install https://github.com/Azumabashi/gemtext2html
```
and use procedures `convert` or `convertFromFiles` (see the test program for details).

## License
MIT
