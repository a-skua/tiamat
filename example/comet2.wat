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
    (local $adr i32)
    (local $val i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    ;; Set register
    (call $set_r1_u (local.get $op)
      (local.tee $val (call $load_u (local.get $adr)))
    )
    (call $set_fr_ofz (local.get $val))
  )
  (func $LD_GR
    (local $op i32)
    (local $val i32)
    (local.set $op (call $load_op_incr))
    ;; Set register
    (call $set_r1_u (local.get $op)
      (local.tee $val (call $get_r2_u (local.get $op)))
    )
    (call $set_fr_ofz (local.get $val))
  )
  (func $ST
    (local $op i32)
    (local $adr i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    (call $store
      (local.get $adr)
      (call $get_r1_u (local.get $op))
    )
  )
  (func $LAD
    (local $op i32)
    (local $adr i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    (call $set_r1_u (local.get $op) (local.get $adr))
  )
  (func $ADDA
    (call $binomial_adrx_s (ref.func $add))
  )
  (func $SUBA
    (call $binomial_adrx_s (ref.func $sub))
  )
  (func $ADDL
    (call $binomial_adrx_u (ref.func $add))
  )
  (func $SUBL
    (call $binomial_adrx_u (ref.func $sub))
  )
  (func $ADDA_GR
    (call $binomial_r1r2_s (ref.func $add))
  )
  (func $SUBA_GR
    (call $binomial_r1r2_s (ref.func $sub))
  )
  (func $ADDL_GR
    (call $binomial_r1r2_u (ref.func $add))
  )
  (func $SUBL_GR
    (call $binomial_r1r2_u (ref.func $sub))
  )
  (func $AND
    (call $binomial_adrx_u (ref.func $and))
  )
  (func $OR
    (call $binomial_adrx_u (ref.func $or))
  )
  (func $XOR
    (call $binomial_adrx_u (ref.func $xor))
  )
  (func $AND_GR
    (call $binomial_r1r2_u (ref.func $and))
  )
  (func $OR_GR
    (call $binomial_r1r2_u (ref.func $or))
  )
  (func $XOR_GR
    (call $binomial_r1r2_u (ref.func $xor))
  )
  (func $CPA
    (call $binomial_adrx
      (ref.func $sub)
      (ref.func $get_r1_s)
      (ref.func $load_s)
      (ref.func $set_fr_cmp)
      (ref.func $set_r1_dummy)
    )
  )
  (func $CPL
    (call $binomial_adrx
      (ref.func $sub)
      (ref.func $get_r1_u)
      (ref.func $load_u)
      (ref.func $set_fr_cmp)
      (ref.func $set_r1_dummy)
    )
  )
  (func $CPA_GR
    (call $binomial_r1r2
      (ref.func $sub)
      (ref.func $get_r1_s)
      (ref.func $get_r2_s)
      (ref.func $set_fr_cmp)
      (ref.func $set_r1_dummy)
    )
  )
  (func $CPL_GR
    (call $binomial_r1r2
      (ref.func $sub)
      (ref.func $get_r1_u)
      (ref.func $get_r2_u)
      (ref.func $set_fr_cmp)
      (ref.func $set_r1_dummy)
    )
  )
  (func $SLA
    (call $binomial_adrx
      (ref.func $shl)
      (ref.func $get_r1_s)
      (ref.func $return_adr_s)
      (ref.func $set_fr_shl)
      (ref.func $set_r1_s)
    )
  )
  (func $SRA
    (call $binomial_adrx
      (ref.func $shr)
      (ref.func $get_r1_s)
      (ref.func $return_adr_s)
      (ref.func $set_fr_shr)
      (ref.func $set_r1_s)
    )
  )
  (func $SLL
    (call $binomial_adrx
      (ref.func $shl)
      (ref.func $get_r1_u)
      (ref.func $return_adr_s)
      (ref.func $set_fr_shl)
      (ref.func $set_r1_u)
    )
  )
  (func $SRL
    (call $binomial_adrx
      (ref.func $shr)
      (ref.func $get_r1_u)
      (ref.func $return_adr_s)
      (ref.func $set_fr_shr)
      (ref.func $set_r1_u)
    )
  )
  (func $JMI
    (local $op i32)
    (local $adr i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    (call $check_r1 (local.get $op))
    (if (call $get_sf)
      (then (global.set $PR (local.get $adr)))
    )
  )
  (func $JNZ
    (local $op i32)
    (local $adr i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    (call $check_r1 (local.get $op))
    (if (i32.eqz (call $get_zf))
      (then (global.set $PR (local.get $adr)))
    )
  )
  (func $JZE
    (local $op i32)
    (local $adr i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    (call $check_r1 (local.get $op))
    (if (call $get_zf)
      (then (global.set $PR (local.get $adr)))
    )
  )
  (func $JUMP
    (local $op i32)
    (local $adr i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    (call $check_r1 (local.get $op))
    (global.set $PR (local.get $adr))
  )
  (func $JPL
    (local $op i32)
    (local $adr i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    (call $check_r1 (local.get $op))
    (if
      (i32.eqz
        (i32.or (call $get_sf) (call $get_zf))
      )
      (then (global.set $PR (local.get $adr)))
    )
  )
  (func $JOV
    (local $op i32)
    (local $adr i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    (call $check_r1 (local.get $op))
    (if (call $get_of)
      (then (global.set $PR (local.get $adr)))
    )
  )
  (func $PUSH
    (local $op i32)
    (local.set $op (call $load_op_incr))
    (call $push
      (call $load_adr_incr (local.get $op))
    )
  )
  (func $POP
    (local $op i32)
    (local.set $op (call $load_op_incr))
    (call $set_r1_u (local.get $op) (call $pop))
  )
  (func $CALL
    (local $op i32)
    (local $adr i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    (call $push (global.get $PR))
    (global.set $PR (local.get $adr))
  )
  (func $RET
    (global.set $PR (call $pop))
  )
  (func $SVC
    (local $op i32)
    (local.set $op (call $load_op_incr))
    (call $call_su
      (table.get $su (call $load_adr_incr (local.get $op)))
    )
  )
  (func $NOP
    call $incr_pr
  )
  ;; Memory Access Functions
  (func $push (param $val i32)
    (call $store (global.get $SP) (local.get $val))
    call $decr_sp
  )
  (func $pop (result i32)
    (call $load_u (global.get $SP))
    call $incr_sp
  )
  (type $load_t (func (param i32) (result i32)))
  (elem declare func $load_u $load_s $return_adr $return_adr_s)
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
  (func $return_adr (param $adr i32) (result i32)
    (local.get $adr)
  )
  (func $return_adr_s (param $adr i32) (result i32)
    (i32.extend16_s (local.get $adr))
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
  (func $load_op_incr (result i32)
    global.get $PR
    call $load_u
    call $incr_pr
  )
  (func $load_adr_incr (param $op i32) (result i32)
    local.get $op
    call $get_adr
    call $incr_pr
  )
  (func $get_adr (param $op i32) (result i32)
    (i32.and
      (i32.add
        (call $load_u (global.get $PR))
        (call $get_x (local.get $op))
      )
      (i32.const 0xffff)
    )
  )
  (type $set_r1_t (func (param i32) (param i32)))
  (elem declare func $set_r1_u $set_r1_s $set_r1_dummy)
  (func $set_r1_s (param $op i32) (param $val i32)
    (call $set_rx
      (i32.shr_u
        (i32.and (local.get $op) (i32.const 0x00f0))
        (i32.const 4)
      )
      (i32.extend16_s (local.get $val))
    )
  )
  (func $set_r1_u (param $op i32) (param $val i32)
    (call $set_rx
      (i32.shr_u
        (i32.and (local.get $op) (i32.const 0x00f0))
        (i32.const 4)
      )
      (i32.and (local.get $val) (i32.const 0xffff))
    )
  )
  (func $set_r1_dummy (param $op i32) (param $val i32)
    ;; Do nothing
  )
  (func $set_rx (param $i i32) (param $val i32)
    (call $check_rx (local.get $i))
    (block $GR7
      (block $GR6
        (block $GR5
          (block $GR4
            (block $GR3
              (block $GR2
                (block $GR1
                  (block $GR0
                    (local.get $i)
                    (br_table $GR0 $GR1 $GR2 $GR3 $GR4 $GR5 $GR6 $GR7)
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
  (func $check_r1 (param $op i32)
    (call $check_rx
      (i32.shr_u
        (i32.and (local.get $op) (i32.const 0x00f0))
        (i32.const 4)
      )
    )
  )
  (func $check_rx (param $i i32)
    (if (i32.gt_u (local.get $i) (i32.const 7))
      (then (unreachable))
    )
  )
  (func $get_x (param $op i32) (result i32)
    (if (result i32)
      (i32.eqz (i32.and (local.get $op) (i32.const 0x000f)))
      (then (i32.const 0))
      (else (call $get_r2_s (local.get $op)))
    )
  )
  (type $get_rx_t (func (param i32) (result i32)))
  (elem declare func $get_r1_u $get_r1_s $get_r2_u $get_r2_s)
  (func $get_r1_s (param $op i32) (result i32)
    (i32.extend16_s
      (call $get_r1_unsafe (local.get $op))
    )
  )
  (func $get_r1_u (param $op i32) (result i32)
    (i32.and
      (call $get_r1_unsafe (local.get $op))
      (i32.const 0xffff)
    )
  )
  (func $get_r1_unsafe (param $op i32) (result i32)
    (call $get_rx
      (i32.shr_u
        (i32.and (local.get $op) (i32.const 0x00f0))
        (i32.const 4)
      )
    )
  )
  (func $get_r2_s (param $op i32) (result i32)
    (i32.extend16_s
      (call $get_r2_unsafe (local.get $op))
    )
  )
  (func $get_r2_u (param $op i32) (result i32)
    (i32.and
      (call $get_r2_unsafe (local.get $op))
      (i32.const 0xffff)
    )
  )
  (func $get_r2_unsafe (param $op i32) (result i32)
    (call $get_rx
      (i32.and (local.get $op) (i32.const 0x000f))
    )
  )
  (func $get_rx (param $i i32) (result i32)
    (call $check_rx (local.get $i))
    (block $GR7
      (block $GR6
        (block $GR5
          (block $GR4
            (block $GR3
              (block $GR2
                (block $GR1
                  (block $GR0
                    (local.get $i)
                    (br_table $GR0 $GR1 $GR2 $GR3 $GR4 $GR5 $GR6 $GR7)
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
    (global.get $GR7)
  )
  ;; Flag Register Update Functions
  (type $set_fr_t (func (param i32)))
  (elem declare func $set_fr_u $set_fr_s $set_fr_cmp $set_fr_shl $set_fr_shr $set_fr_dummy)
  (func $set_fr_u (param $val i32)
    (call $set_of_u (local.get $val))
    (call $set_sf (local.get $val))
    (call $set_zf (local.get $val))
  )
  (func $set_fr_s (param $val i32)
    (call $set_of_s (local.get $val))
    (call $set_sf (local.get $val))
    (call $set_zf (local.get $val))
  )
  (func $set_fr_ofz (param $val i32)
    (call $set_of_z)
    (call $set_sf (local.get $val))
    (call $set_zf (local.get $val))
  )
  (func $set_fr_cmp (param $val i32)
    (call $set_of_z)
    (call $set_sf_cmp (local.get $val))
    (call $set_zf (local.get $val))
  )
  (func $set_fr_shl (param $val i32)
    (call $set_of_shl (local.get $val))
    (call $set_sf (local.get $val))
    (call $set_zf (local.get $val))
  )
  (func $set_fr_shr (param $val i32)
    (call $set_of_shr (local.get $val))
    (call $set_sf (local.get $val))
    (call $set_zf (local.get $val))
  )
  (func $set_fr_dummy (param $val i32)
    ;; Do nothing
  )
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
  (func $set_of_z
    (global.set $FR (i32.and (global.get $FR) (i32.const 0x3)))
  )
  (func $set_of_u (param $val i32)
    (if (i32.gt_u (local.get $val) (i32.const 65535))
      (then (global.set $FR (i32.or (global.get $FR) (i32.const 0x4))))
      (else (global.set $FR (i32.and (global.get $FR) (i32.const 0x3))))
    )
  )
  (func $set_of_shl (param $val i32)
    (if (i32.and (local.get $val) (i32.const 0x10000))
      (then (global.set $FR (i32.or (global.get $FR) (i32.const 0x4))))
      (else (global.set $FR (i32.and (global.get $FR) (i32.const 0x3))))
    )
  )
  (func $set_of_shr (param $val i32)
    (if (i32.and (local.get $val) (i32.const 0x8000_0000))
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
  (func $set_sf_cmp (param $val i32)
    (if (i32.lt_s (local.get $val) (i32.const 0))
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
  (func $get_of (result i32)
    (i32.and (global.get $FR) (i32.const 4))
  )
  (func $get_sf (result i32)
    (i32.and (global.get $FR) (i32.const 2))
  )
  (func $get_zf (result i32)
    (i32.and (global.get $FR) (i32.const 1))
  )
  ;; Helper Functions
  (func $is_signed (param $val i32) (result i32)
    (i32.and (local.get $val) (i32.const 0x8000))
  )
  (type $binomial_t (func (param i32) (param i32) (result i32)))
  (func $binomial_adrx_s (param $calc (ref $binomial_t))
    (call $binomial_adrx
      (local.get $calc)
      (ref.func $get_r1_s)
      (ref.func $load_s)
      (ref.func $set_fr_s)
      (ref.func $set_r1_s)
    )
  )
  (func $binomial_adrx_u (param $calc (ref $binomial_t))
    (call $binomial_adrx
      (local.get $calc)
      (ref.func $get_r1_u)
      (ref.func $load_u)
      (ref.func $set_fr_u)
      (ref.func $set_r1_u)
    )
  )
  (func $binomial_adrx
    (param $calc (ref $binomial_t))
    (param $get_r1 (ref $get_rx_t))
    (param $load (ref $load_t))
    (param $set_fr (ref $set_fr_t))
    (param $set_r1 (ref $set_r1_t))
    (local $op i32)
    (local $adr i32)
    (local $val i32)
    (local.set $op (call $load_op_incr))
    (local.set $adr (call $load_adr_incr (local.get $op)))
    (call_ref $set_r1_t
      (local.get $op)
      (local.tee $val
        (call_ref $binomial_t
          (call_ref $get_rx_t (local.get $op) (local.get $get_r1))
          (call_ref $load_t (local.get $adr) (local.get $load))
          (local.get $calc)
        )
      )
      (local.get $set_r1)
    )
    (call_ref $set_fr_t
      (local.get $val)
      (local.get $set_fr)
    )
  )
  (func $binomial_r1r2_s (param $calc (ref $binomial_t))
    (call $binomial_r1r2
      (local.get $calc)
      (ref.func $get_r1_s)
      (ref.func $get_r2_s)
      (ref.func $set_fr_s)
      (ref.func $set_r1_s)
    )
  )
  (func $binomial_r1r2_u (param $calc (ref $binomial_t))
    (call $binomial_r1r2
      (local.get $calc)
      (ref.func $get_r1_u)
      (ref.func $get_r2_u)
      (ref.func $set_fr_u)
      (ref.func $set_r1_u)
    )
  )
  (func $binomial_r1r2
    (param $calc (ref $binomial_t))
    (param $get_r1 (ref $get_rx_t))
    (param $get_r2 (ref $get_rx_t))
    (param $set_fr (ref $set_fr_t))
    (param $set_r1 (ref $set_r1_t))
    (local $op i32)
    (local $val i32)
    (local.set $op (call $load_op_incr))
    (call_ref $set_r1_t
      (local.get $op)
      (local.tee $val
        (call_ref $binomial_t
          (call_ref $get_rx_t (local.get $op) (local.get $get_r1))
          (call_ref $get_rx_t (local.get $op) (local.get $get_r2))
          (local.get $calc)
        )
      )
      (local.get $set_r1)
    )
    (call_ref $set_fr_t (local.get $val) (local.get $set_fr))
  )
  ;; Function Table
  (elem declare func $add $sub $and $or $xor $shl $shr)
  (func $add (param $a i32) (param $b i32) (result i32)
    (i32.add (local.get $a) (local.get $b))
  )
  (func $sub (param $a i32) (param $b i32) (result i32)
    (i32.sub (local.get $a) (local.get $b))
  )
  (func $and (param $a i32) (param $b i32) (result i32)
    (i32.and (local.get $a) (local.get $b))
  )
  (func $or (param $a i32) (param $b i32) (result i32)
    (i32.or (local.get $a) (local.get $b))
  )
  (func $xor (param $a i32) (param $b i32) (result i32)
    (i32.xor (local.get $a) (local.get $b))
  )
  (func $shl (param $a i32) (param $b i32) (result i32)
    (i32.shl (local.get $a) (local.get $b))
  )
  (func $shr (param $a i32) (param $b i32) (result i32)
    (i32.rotr (local.get $a) (local.get $b))
  )
)
