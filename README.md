# tiamat
virtual computer COMET2 emulator and virtual language CASL2 compiler.

## links
- [pub.dev](https://pub.dev/packages/tiamat)
- [web app](https://a-skua.github.io/tiamat/)

## supervisor call

### SVC 1; read
- `GR1`: input buffer
- `GR2`: input length

```
  LAD GR1,IBUF
  LAD GR2,32
  SVC 1
```

### SVC 2; write
- `GR1`: output buffer
- `GR2`: output length

```
  LAD GR1,IBUF
  LAD GR2,32
  SVC 1
```

## Specification

[IPA Shiken Yougo ver 4.2](https://www.jitec.ipa.go.jp/1_13download/shiken_yougo_ver4_2.pdf)

### CASL2 Format
```
# with operand
[<label>]<space><opecode><spece><operand>[<space>[<comment>]]

# without operand
[<label>]<space><opecode>[<space>[<semicoron>[<comment>]]]

# comment line
[<space>]<semicoron>[<comment>]
```
