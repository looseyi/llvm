; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -verify-coalescing | FileCheck %s

define i32* @test1(i32* %P, i32 %X) {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    andl $-4, %eax
; CHECK-NEXT:    addl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    retl
  %Y = lshr i32 %X, 2
  %gep.upgrd.1 = zext i32 %Y to i64
  %P2 = getelementptr i32, i32* %P, i64 %gep.upgrd.1
  ret i32* %P2
}

define i32* @test2(i32* %P, i32 %X) {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    shll $4, %eax
; CHECK-NEXT:    addl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    retl
  %Y = shl i32 %X, 2
  %gep.upgrd.2 = zext i32 %Y to i64
  %P2 = getelementptr i32, i32* %P, i64 %gep.upgrd.2
  ret i32* %P2
}

define i32* @test3(i32* %P, i32 %X) {
; CHECK-LABEL: test3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    andl $-4, %eax
; CHECK-NEXT:    addl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    retl
  %Y = ashr i32 %X, 2
  %P2 = getelementptr i32, i32* %P, i32 %Y
  ret i32* %P2
}

define fastcc i32 @test4(i32* %d) {
; CHECK-LABEL: test4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movzbl 3(%ecx), %eax
; CHECK-NEXT:    retl
  %tmp4 = load i32, i32* %d
  %tmp512 = lshr i32 %tmp4, 24
  ret i32 %tmp512
}

; Ensure that we don't fold away shifts which have multiple uses, as they are
; just re-introduced for the second use.

define i64 @test5(i16 %i, i32* %arr) {
; CHECK-LABEL: test5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    shrl $11, %eax
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    addl (%ecx,%eax,4), %eax
; CHECK-NEXT:    setb %dl
; CHECK-NEXT:    retl
  %i.zext = zext i16 %i to i32
  %index = lshr i32 %i.zext, 11
  %index.zext = zext i32 %index to i64
  %val.ptr = getelementptr inbounds i32, i32* %arr, i64 %index.zext
  %val = load i32, i32* %val.ptr
  %val.zext = zext i32 %val to i64
  %sum = add i64 %val.zext, %index.zext
  ret i64 %sum
}

; We should not crash because an undef shift was created.

define i32 @overshift(i32 %a) {
; CHECK-LABEL: overshift:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retl
  %shr = lshr i32 %a, 33
  %xor = xor i32 1, %shr
  ret i32 %xor
}

