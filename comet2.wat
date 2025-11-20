(module
  (import "env" "call_supervisor" (func $call_su (param (ref null extern))))
  ;; Memories
  (memory $mem i32 2)
  (export "memory" (memory $mem))
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
    (local.set $op (i32.and (call $load_u (global.get $PR)) (i32.const 0xff00)))
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
    (local.set $op (call $load_u (global.get $PR)))
    call $incr_pr
    ;; Get value from memory
    (local.set $val (call $load_u (call $get_adr (local.get $op))))
    call $incr_pr
    ;; Set register
    (call $set_r_u (local.get $op) (local.get $val))
    ;; OF not affected
    (call $set_zf (local.get $val))
    (call $set_sf (local.get $val))
  )
  (func $LD_GR
    (local $op i32)
    (local $val i32)
    ;; Fetch operand
    (local.set $op (call $load_u (global.get $PR)))
    call $incr_pr
    ;; Load value from memory
    (local.set $val (call $get_r2 (local.get $op)))
    ;; Set register
    (call $set_r1_u (local.get $op) (local.get $val))
    ;; OF not affected
    (call $set_zf (local.get $val))
    (call $set_sf (local.get $val))
  )
  (func $ST
    (local $op i32)
    (local $adr i32)
    ;; Fetch operand
    (local.set $op (call $load_u (global.get $PR)))
    call $incr_pr
    ;; Get target adress
    (local.set $adr (call $get_adr (local.get $op)))
    call $incr_pr
    ;; Store value to memory
    (call $store (local.get $adr) (call $get_r_u (local.get $op)))
  )
  (func $LAD
    (local $op i32)
    (local $adr i32)
    ;; Fetch operand
    (local.set $op (call $load_u (global.get $PR)))
    call $incr_pr
    ;; Get target adress
    (local.set $adr (call $get_adr (local.get $op)))
    call $incr_pr
    ;; Set register
    (call $set_r_u (local.get $op) (local.get $adr))
  )
  (func $ADDA
    (call $binomial_s (ref.func $add))
  )
  (func $SUBA
    (call $binomial_s (ref.func $sub))
  )
  (func $ADDL
    (call $binomial_u (ref.func $add))
  )
  (func $SUBL
    (call $binomial_u (ref.func $sub))
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
    (local $adr i32)
    ;; Fetch operand
    (local.set $op (call $load_u (global.get $PR)))
    call $incr_pr
    ;; Get target adress
    (local.set $adr (call $get_adr (local.get $op)))
    call $incr_pr
    ;; Push value onto stack
    (call $store (global.get $SP) (local.get $adr))
    call $decr_sp
  )
  (func $POP
    (local $op i32)
    (local $val i32)
    ;; Fetch operand
    (local.set $op (call $load_u (global.get $PR)))
    call $incr_pr
    ;; Pop value from stack
    (local.set $val (call $load_u (global.get $SP)))
    call $incr_sp
    ;; Set register
    (call $set_r_u (local.get $op) (local.get $val))
  )
  (func $CALL
    (local $op i32)
    (local $adr i32)
    ;; Fetch operand
    (local.set $op (call $load_u (global.get $PR)))
    call $incr_pr
    ;; Get target adress
    (local.set $adr (call $get_adr (local.get $op)))
    call $incr_pr
    ;; Push PR onto stack
    (call $store (global.get $SP) (global.get $PR))
    call $decr_sp
    (global.set $PR (local.get $adr))
  )
  (func $RET
    (local $adr i32)
    ;; Pop return adress from stack
    (local.set $adr (call $load_u (global.get $SP)))
    call $incr_sp
    ;; Set PR to return adress
    (global.set $PR (local.get $adr))
  )
  (func $SVC
    (local $op i32)
    (local $adr i32)
    ;; Fetch operand
    (local.set $op (call $load_u (global.get $PR)))
    call $incr_pr
    ;; Get target adress
    (local.set $adr (call $get_adr (local.get $op)))
    call $incr_pr
    (call $call_su (table.get $su (local.get $adr)))
  )
  (func $NOP
    return_call $incr_pr
  )
  ;; Memory Access Functions
  (func $load_u (param $adr i32) (result i32)
    (i32.load16_u $mem
      (i32.mul (local.get $adr) (i32.const 2))
    )
  )
  (func $load_s (param $adr i32) (result i32)
    (i32.load16_s $mem
      (i32.mul (local.get $adr) (i32.const 2))
    )
  )
  (func $store (param $adr i32) (param $val i32)
    (i32.store16 $mem
      (i32.mul (local.get $adr) (i32.const 2))
      (local.get $val)
    )
  )
  ;; Increment and Decrement Functions
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
  ;; Operand Decoding Functions
  (func $get_adr (param $op i32) (result i32)
    (i32.and
      (i32.add
        (call $load_u (global.get $PR))
        (call $get_x (local.get $op))
      )
      (i32.const 0xffff)
    )
  )
  (func $get_r_s (param $op i32) (result i32)
    (i32.extend16_s (call $get_r_u (local.get $op)))
  )
  (func $get_r_u (param $op i32) (result i32)
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
                  (return (i32.and (global.get $GR0) (i32.const 0xffff)))
                )
                (return (i32.and (global.get $GR1) (i32.const 0xffff)))
              )
              (return (i32.and (global.get $GR2) (i32.const 0xffff)))
            )
            (return (i32.and (global.get $GR3) (i32.const 0xffff)))
          )
          (return (i32.and (global.get $GR4) (i32.const 0xffff)))
        )
        (return (i32.and (global.get $GR5) (i32.const 0xffff)))
      )
      (return (i32.and (global.get $GR6) (i32.const 0xffff)))
    )
    (i32.and (global.get $GR7) (i32.const 0xffff))
  )
  (func $set_r_s (param $op i32) (param $val i32)
    (local.set $val (i32.extend16_s (local.get $val)))
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
  (func $set_r_u (param $op i32) (param $val i32)
    (local.set $val (i32.and (local.get $val) (i32.const 0xffff)))
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
  (func $set_r1_u (param $op i32) (param $val i32)
    (call $set_r_u (local.get $op) (local.get $val))
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
  ;; Flag Register Update Functions
  (func $set_of_s (param $val i32)
    (i32.or
      (i32.gt_s (local.get $val) (i32.const 32767))
      (i32.lt_s (local.get $val) (i32.const -32768))
    )
    (if
      (then (global.set $FR (i32.or (global.get $FR) (i32.const 0x4))))
      (else (global.set $FR (i32.and (global.get $FR) (i32.const 0x3))))
    )
  )
  (func $set_of_u (param $val i32)
    (i32.gt_u (local.get $val) (i32.const 65535))
    (if
      (then (global.set $FR (i32.or (global.get $FR) (i32.const 0x4))))
      (else (global.set $FR (i32.and (global.get $FR) (i32.const 0x3))))
    )
  )
  (func $set_sf (param $val i32)
    (if (call $is_signed (local.get $val))
      (then (global.set $FR (i32.or (global.get $FR) (i32.const 0x2))))
      (else (global.set $FR (i32.and (global.get $FR) (i32.const 0x5))))
    )
  )
  (func $set_zf (param $val i32)
    (if (i32.eqz (i32.and (local.get $val) (i32.const 0xffff)))
      (then (global.set $FR (i32.or (global.get $FR) (i32.const 0x1))))
      (else (global.set $FR (i32.and (global.get $FR) (i32.const 0x6))))
    )
  )
  ;; Helper Functions
  (func $is_signed (param $val i32) (result i32)
    (i32.xor
      (i32.eqz (i32.and (local.get $val) (i32.const 0x8000)))
      (i32.const 1)
    )
  )
  (type $binomial_t (func (param i32) (param i32) (result i32)))
  (func $binomial_s (param $fn (ref null $binomial_t))
    (local $op i32)
    (local $val i32)
    ;; Fetch operand
    (local.set $op (call $load_u (global.get $PR)))
    call $incr_pr
    ;; Get value from memory and add to register
    (call $set_r_s
      (local.get $op)
      (local.tee $val
        (call_ref $binomial_t
          (call $get_r_s (local.get $op))
          (call $load_s (call $get_adr (local.get $op)))
          (local.get $fn)
        )
      )
    )
    call $incr_pr
    ;; Set flags
    (call $set_of_s (local.get $val))
    (call $set_zf (local.get $val))
    (call $set_sf (local.get $val))
  )
  (func $binomial_u (param $fn (ref null $binomial_t))
    (local $op i32)
    (local $val i32)
    ;; Fetch operand
    (local.set $op (call $load_u (global.get $PR)))
    call $incr_pr
    ;; Get value from memory and add to register
    (call $set_r_u
      (local.get $op)
      (local.tee $val
        (call_ref $binomial_t
          (call $get_r_u (local.get $op))
          (call $load_u (call $get_adr (local.get $op)))
          (local.get $fn)
        )
      )
    )
    call $incr_pr
    ;; Set flags
    (call $set_of_u (local.get $val))
    (call $set_zf (local.get $val))
    (call $set_sf (local.get $val))
  )
  ;; Function Table
  (elem declare func $add $sub)
  (func $add (param $a i32) (param $b i32) (result i32)
    (i32.add (local.get $a) (local.get $b))
  )
  (func $sub (param $a i32) (param $b i32) (result i32)
    (i32.sub (local.get $a) (local.get $b))
  )
)
