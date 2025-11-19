(module
  (import "env" "call_supervisor" (func $call_supervisor (param (ref null extern))))
  ;; Memories
  (memory $external i32 2)
  (memory $internal i32 1)
  (export "memory" (memory $external))
  ;; Supervisor Function Table
  (table $su i32 16 (ref null extern))
  (export "supervisor" (table $su))
  ;; General Registers
  (global $GR0 (mut i32) (i32.const 0))
  (export "GR0" (global $GR0))
  (global $GR1 (mut i32) (i32.const 0))
  (export "GR1" (global $GR1))
  (global $GR2 (mut i32) (i32.const 0))
  (export "GR2" (global $GR2))
  (global $GR3 (mut i32) (i32.const 0))
  (export "GR3" (global $GR3))
  (global $GR4 (mut i32) (i32.const 0))
  (export "GR4" (global $GR4))
  (global $GR5 (mut i32) (i32.const 0))
  (export "GR5" (global $GR5))
  (global $GR6 (mut i32) (i32.const 0))
  (export "GR6" (global $GR6))
  (global $GR7 (mut i32) (i32.const 0))
  (export "GR7" (global $GR7))
  ;; Program Register
  (global $PR (mut i32) (i32.const 0))
  (export "PR" (global $PR))
  ;; Stack Pointer Register
  (global $SP (mut i32) (i32.const 0))
  (export "SP" (global $SP))
  ;; Flag Register
  (global $FR (mut i32) (i32.const 0))
  (export "FR" (global $FR))
  (func (export "reset")
    (global.set $GR0 (i32.const 0))
    (global.set $GR1 (i32.const 0))
    (global.set $GR2 (i32.const 0))
    (global.set $GR3 (i32.const 0))
    (global.set $GR4 (i32.const 0))
    (global.set $GR5 (i32.const 0))
    (global.set $GR6 (i32.const 0))
    (global.set $GR7 (i32.const 0))
    (global.set $PR (i32.const 0))
    (global.set $SP (i32.const 0xffff))
    (global.set $FR (i32.const 0))
  )
  ;; |F  C|B  8|7  4|3  0|
  ;; |-------------------|
  ;; | opecode | operand |
  ;; |    -    |r/r1|x/r2|
  ;; |-------------------|
  ;; |      address      |
  ;; |-------------------|
  (func (export "step")
    (local $op i32)
    (local.set $op (i32.and (call $load (global.get $PR)) (i32.const 0xff00)))
    ;; LD r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x1000)))
    (if (then (return_call $LD)))
    ;; ST r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x1100)))
    (if (then (return_call $ST)))
    ;; LAD r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x1200)))
    (if (then (return_call $LAD)))
    ;; LD r1,r2
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x1400)))
    (if (then (return_call $LD_GR)))
    ;; ADDA r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x2000)))
    (if (then (return_call $ADDA)))
    ;; SUBA r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x2100)))
    (if (then (return_call $SUBA)))
    ;; ADDL r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x2200)))
    (if (then (return_call $ADDL)))
    ;; SUBL r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x2300)))
    (if (then (return_call $SUBL)))
    ;; ADDA r1,r2
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x2400)))
    (if (then (return_call $ADDA_GR)))
    ;; SUBA r1,r2
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x2500)))
    (if (then (return_call $SUBA_GR)))
    ;; ADDL r1,r2
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x2600)))
    (if (then (return_call $ADDL_GR)))
    ;; SUBL r1,r2
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x2700)))
    (if (then (return_call $SUBL_GR)))
    ;; AND r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x3000)))
    (if (then (return_call $AND)))
    ;; OR r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x3100)))
    (if (then (return_call $OR)))
    ;; XOR r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x3200)))
    (if (then (return_call $XOR)))
    ;; AND r1,r2
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x3400)))
    (if (then (return_call $AND_GR)))
    ;; OR r1,r2
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x3500)))
    (if (then (return_call $OR_GR)))
    ;; XOR r1,r2
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x3600)))
    (if (then (return_call $XOR_GR)))
    ;; CPA r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x4000)))
    (if (then (return_call $CPA)))
    ;; CPL r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x4100)))
    (if (then (return_call $CPL)))
    ;; CPA r1,r2
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x4400)))
    (if (then (return_call $CPA_GR)))
    ;; CPL r1,r2
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x4500)))
    (if (then (return_call $CPL_GR)))
    ;; SLA r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x5000)))
    (if (then (return_call $SLA)))
    ;; SRA r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x5100)))
    (if (then (return_call $SRA)))
    ;; SLL r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x5200)))
    (if (then (return_call $SLL)))
    ;; SRL r,adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x5300)))
    (if (then (return_call $SRL)))
    ;; JMI adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x6100)))
    (if (then (return_call $JMI)))
    ;; JNZ adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x6200)))
    (if (then (return_call $JNZ)))
    ;; JZE adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x6300)))
    (if (then (return_call $JZE)))
    ;; JUMP adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x6400)))
    (if (then (return_call $JUMP)))
    ;; JPL adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x6500)))
    (if (then (return_call $JPL)))
    ;; JOV adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x6600)))
    (if (then (return_call $JOV)))
    ;; PUSH adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x7000)))
    (if (then (return_call $PUSH)))
    ;; POP r
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x7100)))
    (if (then (return_call $POP)))
    ;; CALL adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x8000)))
    (if (then (return_call $CALL)))
    ;; RET
    (i32.eqz (i32.xor (local.get $op) (i32.const 0x8100)))
    (if (then (return_call $RET)))
    ;; SVC adr,x
    (i32.eqz (i32.xor (local.get $op) (i32.const 0xf000)))
    (if (then (return_call $SVC)))
    ;; NOP
    call $NOP
  )
  (func $LD
    (local $op i32)
    (local $val i32)
    ;; Fetch operand
    (local.set $op (call $load (global.get $PR)))
    call $incr_pr
    ;; Load value from memory
    (local.set $val (call $load_addr (local.get $op)))
    call $incr_pr
    ;; Set register
    (call $set_r (local.get $op) (local.get $val))
    ;; OF not affected
    (call $set_zf (local.get $val))
    (call $set_sf (local.get $val))
  )
  (func $LD_GR
    (local $op i32)
    (local $val i32)
    ;; Fetch operand
    (local.set $op (call $load (global.get $PR)))
    call $incr_pr
    ;; Load value from memory
    (local.set $val (call $get_r2 (local.get $op)))
    ;; Set register
    (call $set_r1 (local.get $op) (local.get $val))
    ;; OF not affected
    (call $set_zf (local.get $val))
    (call $set_sf (local.get $val))
  )
  (func $ST
    (local $op i32)
    (local $addr i32)
    ;; Fetch operand
    (local.set $op (call $load (global.get $PR)))
    call $incr_pr
    ;; Get target address
    (local.set $addr (call $get_addr (local.get $op)))
    call $incr_pr
    ;; Store value to memory
    (call $store (local.get $addr) (call $get_r (local.get $op)))
  )
  (func $LAD
    (local $op i32)
    (local $addr i32)
    ;; Fetch operand
    (local.set $op (call $load (global.get $PR)))
    call $incr_pr
    ;; Get target address
    (local.set $addr (call $get_addr (local.get $op)))
    call $incr_pr
    ;; Set register
    (call $set_r (local.get $op) (local.get $addr))
  )
  (func $ADDA
    unreachable
  )
  (func $SUBA
    unreachable
  )
  (func $ADDL
    unreachable
  )
  (func $SUBL
    unreachable
  )
  (func $ADDA_GR
    unreachable
  )
  (func $SUBA_GR
    unreachable
  )
  (func $ADDL_GR
    unreachable
  )
  (func $SUBL_GR
    unreachable
  )
  (func $AND
    unreachable
  )
  (func $OR
    unreachable
  )
  (func $XOR
    unreachable
  )
  (func $AND_GR
    unreachable
  )
  (func $OR_GR
    unreachable
  )
  (func $XOR_GR
    unreachable
  )
  (func $CPA
    unreachable
  )
  (func $CPL
    unreachable
  )
  (func $CPA_GR
    unreachable
  )
  (func $CPL_GR
    unreachable
  )
  (func $SLA
    unreachable
  )
  (func $SRA
    unreachable
  )
  (func $SLL
    unreachable
  )
  (func $SRL
    unreachable
  )
  (func $JMI
    unreachable
  )
  (func $JNZ
    unreachable
  )
  (func $JZE
    unreachable
  )
  (func $JUMP
    unreachable
  )
  (func $JPL
    unreachable
  )
  (func $JOV
    unreachable
  )
  (func $PUSH
    (local $op i32)
    (local $addr i32)
    ;; Fetch operand
    (local.set $op (call $load (global.get $PR)))
    call $incr_pr
    ;; Get target address
    (local.set $addr (call $get_addr (local.get $op)))
    call $incr_pr
    ;; Push value onto stack
    (call $store (global.get $SP) (local.get $addr))
    call $decr_sp
  )
  (func $POP
    (local $op i32)
    (local $val i32)
    ;; Fetch operand
    (local.set $op (call $load (global.get $PR)))
    call $incr_pr
    ;; Pop value from stack
    (local.set $val (call $load (global.get $SP)))
    call $incr_sp
    ;; Set register
    (call $set_r (local.get $op) (local.get $val))
  )
  (func $CALL
    (local $op i32)
    (local $addr i32)
    ;; Fetch operand
    (local.set $op (call $load (global.get $PR)))
    call $incr_pr
    ;; Get target address
    (local.set $addr (call $get_addr (local.get $op)))
    call $incr_pr
    ;; Push PR onto stack
    (call $store (global.get $SP) (global.get $PR))
    call $decr_sp
    (global.set $PR (local.get $addr))
  )
  (func $RET
    (local $addr i32)
    ;; Pop return address from stack
    (local.set $addr (call $load (global.get $SP)))
    call $incr_sp
    ;; Set PR to return address
    (global.set $PR (local.get $addr))
  )
  (func $SVC
    (local $op i32)
    (local $addr i32)
    ;; Fetch operand
    (local.set $op (call $load (global.get $PR)))
    call $incr_pr
    ;; Get target address
    (local.set $addr (call $get_addr (local.get $op)))
    call $incr_pr
    (call $call_supervisor (table.get $su (local.get $addr)))
  )
  (func $NOP
    return_call $incr_pr
  )
  (func $load (param $addr i32) (result i32)
    (i32.load16_u $external
      (i32.mul (local.get $addr) (i32.const 2))
    )
  )
  (func $store (param $addr i32) (param $val i32)
    (i32.store16 $external
      (i32.mul (local.get $addr) (i32.const 2))
      (local.get $val)
    )
  )
  (func $incr_pr
    (global.set $PR
      (i32.and
        (i32.add (global.get $PR) (i32.const 1))
        (i32.const 0xffff)
      )
    )
  )
  (func $incr_sp
    (global.set $SP
      (i32.and
        (i32.add (global.get $SP) (i32.const 1))
        (i32.const 0xffff)
      )
    )
  )
  (func $decr_sp
    (global.set $SP
      (i32.and
        (i32.sub (global.get $SP) (i32.const 1))
        (i32.const 0xffff)
      )
    )
  )
  (func $load_addr (param $op i32) (result i32)
    (call $load
      (call $get_addr (local.get $op))
    )
  )
  (func $get_addr (param $op i32) (result i32)
    (i32.and
      (i32.add
        (call $load (global.get $PR))
        (call $get_x (local.get $op))
      )
      (i32.const 0xffff)
    )
  )
  (func $get_r (param $op i32) (result i32)
    (block $GR7
      (block $GR6
        (block $GR5
          (block $GR4
            (block $GR3
              (block $GR2
                (block $GR1
                  (block $GR0
                    (block $trap
                      (i32.shr_u
                        (i32.and (local.get $op) (i32.const 0x00f0))
                        (i32.const 4)
                      )
                      (br_table $GR0 $GR1 $GR2 $GR3 $GR4 $GR5 $GR6 $GR7 $trap)
                    )
                    unreachable
                  )
                  (return (global.get $GR0))
                )
                (return (global.get $GR1))
              )
              (return (global.get $GR2))
            )
            (return (global.get $GR3))
          )
          (return (global.get $GR4))
        )
        (return (global.get $GR5))
      )
      (return (global.get $GR6))
    )
    global.get $GR7
  )
  (func $set_r (param $op i32) (param $val i32)
    (block $GR7
      (block $GR6
        (block $GR5
          (block $GR4
            (block $GR3
              (block $GR2
                (block $GR1
                  (block $GR0
                    (block $trap
                      (i32.shr_u
                        (i32.and (local.get $op) (i32.const 0x00f0))
                        (i32.const 4)
                      )
                      (br_table $GR0 $GR1 $GR2 $GR3 $GR4 $GR5 $GR6 $GR7 $trap)
                    )
                    unreachable
                  )
                  (return (global.set $GR0 (local.get $val)))
                )
                (return (global.set $GR1 (local.get $val)))
              )
              (return (global.set $GR2 (local.get $val)))
            )
            (return (global.set $GR3 (local.get $val)))
          )
          (return (global.set $GR4 (local.get $val)))
        )
        (return (global.set $GR5 (local.get $val)))
      )
      (return (global.set $GR6 (local.get $val)))
    )
    (global.set $GR7 (local.get $val))
  )
  (func $set_r1 (param $op i32) (param $val i32)
    (call $set_r (local.get $op) (local.get $val))
  )
  (func $get_x (param $op i32) (result i32)
    (block $GR7
      (block $GR6
        (block $GR5
          (block $GR4
            (block $GR3
              (block $GR2
                (block $GR1
                  (block $GR0
                    (block $trap
                      (i32.and (local.get $op) (i32.const 0x000f))
                      (br_table $GR0 $GR1 $GR2 $GR3 $GR4 $GR5 $GR6 $GR7 $trap)
                    )
                    unreachable
                  )
                  (return (i32.const 0))
                )
                (return (global.get $GR1))
              )
              (return (global.get $GR2))
            )
            (return (global.get $GR3))
          )
          (return (global.get $GR4))
        )
        (return (global.get $GR5))
      )
      (return (global.get $GR6))
    )
    global.get $GR7
  )
  (func $get_r2 (param $op i32) (result i32)
    (block $GR7
      (block $GR6
        (block $GR5
          (block $GR4
            (block $GR3
              (block $GR2
                (block $GR1
                  (block $GR0
                    (block $trap
                      (i32.and (local.get $op) (i32.const 0x000f))
                      (br_table $GR0 $GR1 $GR2 $GR3 $GR4 $GR5 $GR6 $GR7 $trap)
                    )
                    unreachable
                  )
                  (return (global.get $GR0))
                )
                (return (global.get $GR1))
              )
              (return (global.get $GR2))
            )
            (return (global.get $GR3))
          )
          (return (global.get $GR4))
        )
        (return (global.get $GR5))
      )
      (return (global.get $GR6))
    )
    global.get $GR7
  )
  (func $set_zf (param $val i32)
    (if (i32.eqz (local.get $val))
      (then (global.set $FR (i32.or (global.get $FR) (i32.const 0x0001))))
      (else (global.set $FR (i32.and (global.get $FR) (i32.const 0xfffe))))
    )
  )
  (func $set_sf (param $val i32)
    (i32.store16 $internal (i32.const 0) (local.get $val))
    (i32.lt_s (i32.load16_s $internal (i32.const 0)) (i32.const 0))
    (if
      (then (global.set $FR (i32.or (global.get $FR) (i32.const 0x0002))))
      (else (global.set $FR (i32.and (global.get $FR) (i32.const 0xfffd))))
    )
  )
)
