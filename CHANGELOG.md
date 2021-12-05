## 0.5.0-2
0.5.0 preview version.
Change Comet2's methods and fields.
See `example/main.dart` for upsage.

- add named arg `onChangeStatus` on Comet2 constructor.
- Comet2's method; `void run()` change to `Future<Resource> run()`

## 0.5.0-1
0.5.0 preview version.
Change Comet2's fields.
See `example/main.dart` for upsage.

## 0.4.1-1
## 0.4.1
Bugfix

- Bugfix: Failed Parse String.

## 0.4.0
Breaking changes!

- Cahnged Casl2 Parser.
  See `example/main.dart` for usage.

## 0.3.0-nullsafety
- changed Casl2.
- `Casl2.compile` thorws CompileException
  when parse error.
## 0.2.0-nullsafety
- refactoring Comet2.
- add class `Device` and remove field `Comet2.sv`
  ```
  final comet2 = Comet2();

  // ~0.1.3
  comet2.sv.write = (s) => print(s);

  // ^0.2.0
  comet2.device.output = (s) => print(s);
  ```
- deprecated methods `Resource.getGR(i)` and more
  ```
  final comet2 = Comet2();
  final r = comet2.resource;

  // ~0.1.3
  r.setGR(1, 100);
  if (r.SF) {
    // any...
  }

  // ^0.2.0
  final gr = r.generalRegisters;
  gr[1] = 100;

  final fr = r.flagRegister;
  if (fr.isSign) {
    // any...
  }
  ```
- changed argument on `Comet2.exec`
  ```
  final comet2 = Comet2();
  final code = <int>[/* any code */];

  // ~0.1.3
  final r = Resource;
  r.memory.setAll(r.PR, code);
  comet2.exec(r);

  // ^0.2.0
  comet2.load(code);
  comet2.exec();
  ```

## 0.1.3-nullsafety
- change casl2 parser.  
  DC operand can now be identified correctly.
  ```
          DC      'hello, world!',-1
          DC      'It''s a Small World.',-1
  ```

## 0.1.2-nullsafety
- change casl2 parser.  
  comments can now be identified correctly.
  ```
  MAIN    START                   ; comment
  ; initialize GR1
          XOR     GR1,GR1
  ;       LAD     GR1,5
          LAD     GR1,2,GR1       comment!
          RET
          END
  ```

## 0.1.1-nullsafety
- supported web.

## 0.1.0-nullsafety

- first version.
