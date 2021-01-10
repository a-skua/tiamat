# tiamat
virtual computer COMET2 emulator and virtual language CASL2 compiler.  
[pub.dev](https://pub.dev/packages/tiamat)

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
