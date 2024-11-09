# tiamat
virtual computer COMET2 emulator and virtual language CASL2 compiler.

## links
- [pub.dev](https://pub.dev/packages/tiamat)
- [web app](https://a-skua.github.io/tiamat/)


## macros

### IN
- `GR1`: input buffer
- `GR2`: input length

```
  LAD     GR1,IBUF  ; buffer
  LAD     GR2,32    ; length
  SVC     1         ; input
```

### OUT
- `GR1`: output buffer
- `GR2`: output length

```
  LAD     GR1,IBUF  ; buffer
  LAD     GR2,32    ; length
  SVC     2         ; output
```

## Specification

[SPEC.md](SPEC.md)

### CASL2 Format
```
# with operand
[<label>]<space><opecode><spece><operand>[<space>[<comment>]]

# without operand
[<label>]<space><opecode>[<space>[<semicoron>[<comment>]]]

# comment line
[<space>]<semicoron>[<comment>]
```

## Extended
Address 1 ~ 99 are supervisor.
Program load to address 100.