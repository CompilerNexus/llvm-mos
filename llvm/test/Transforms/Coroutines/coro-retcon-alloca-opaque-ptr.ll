; NOTE: Assertions have been autogenerated by utils/update_test_checks.py

; RUN: opt < %s -passes='default<O2>' -S | FileCheck %s

target datalayout = "p:64:64:64"

declare {ptr, ptr, i32} @prototype_f(ptr, i1)
define {ptr, ptr, i32} @f(ptr %buffer, i32 %n, { i32 } %dummy) {
; CHECK-LABEL: @f(
; CHECK-NEXT:  coro.return:
; CHECK-NEXT:    [[N_VAL_SPILL_ADDR:%.*]] = getelementptr inbounds nuw i8, ptr [[BUFFER:%.*]], i64 8
; CHECK-NEXT:    store i32 [[N:%.*]], ptr [[N_VAL_SPILL_ADDR]], align 4
; CHECK-NEXT:    [[TMP0:%.*]] = tail call ptr @allocate(i32 [[N]])
; CHECK-NEXT:    store ptr [[TMP0]], ptr [[BUFFER]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = insertvalue { ptr, ptr, i32 } { ptr @f.resume.0, ptr poison, i32 poison }, ptr [[TMP0]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = insertvalue { ptr, ptr, i32 } [[TMP1]], i32 [[N]], 2
; CHECK-NEXT:    ret { ptr, ptr, i32 } [[TMP2]]
;
entry:
  %id = call token @llvm.coro.id.retcon(i32 1024, i32 8, ptr %buffer, ptr @prototype_f, ptr @allocate, ptr @deallocate)
  %hdl = call ptr @llvm.coro.begin(token %id, ptr null)
  br label %loop

loop:
  %n.val = phi i32 [ %n, %entry ], [ %inc, %resume ]
  %alloca = call token @llvm.coro.alloca.alloc.i32(i32 %n.val, i32 8)
  %ptr = call ptr @llvm.coro.alloca.get(token %alloca)
  %unwind = call i1 (...) @llvm.coro.suspend.retcon.i1(ptr %ptr, i32 %n.val)
  call void @llvm.coro.alloca.free(token %alloca)
  br i1 %unwind, label %cleanup, label %resume

resume:
  %inc = add i32 %n.val, 1
  br label %loop

cleanup:
  call i1 @llvm.coro.end(ptr %hdl, i1 0, token none)
  unreachable
}


declare {ptr, i32} @prototype_g(ptr, i1)
define {ptr, i32} @g(ptr %buffer, i32 %n) {
; CHECK-LABEL: @g(
; CHECK-NEXT:  coro.return:
; CHECK-NEXT:    store i32 [[N:%.*]], ptr [[BUFFER:%.*]], align 4
; CHECK-NEXT:    [[TMP0:%.*]] = zext i32 [[N]] to i64
; CHECK-NEXT:    [[TMP1:%.*]] = alloca i8, i64 [[TMP0]], align 8
; CHECK-NEXT:    tail call void @use(ptr nonnull [[TMP1]])
; CHECK-NEXT:    [[TMP2:%.*]] = insertvalue { ptr, i32 } { ptr @g.resume.0, i32 poison }, i32 [[N]], 1
; CHECK-NEXT:    ret { ptr, i32 } [[TMP2]]
;
entry:
  %id = call token @llvm.coro.id.retcon(i32 1024, i32 8, ptr %buffer, ptr @prototype_g, ptr @allocate, ptr @deallocate)
  %hdl = call ptr @llvm.coro.begin(token %id, ptr null)
  br label %loop

loop:
  %n.val = phi i32 [ %n, %entry ], [ %inc, %resume ]
  %alloca = call token @llvm.coro.alloca.alloc.i32(i32 %n.val, i32 8)
  %ptr = call ptr @llvm.coro.alloca.get(token %alloca)
  call void @use(ptr %ptr)
  call void @llvm.coro.alloca.free(token %alloca)
  %unwind = call i1 (...) @llvm.coro.suspend.retcon.i1(i32 %n.val)
  br i1 %unwind, label %cleanup, label %resume

resume:
  %inc = add i32 %n.val, 1
  br label %loop

cleanup:
  call i1 @llvm.coro.end(ptr %hdl, i1 0, token none)
  unreachable
}

declare token @llvm.coro.id.retcon(i32, i32, ptr, ptr, ptr, ptr)
declare ptr @llvm.coro.begin(token, ptr)
declare i1 @llvm.coro.suspend.retcon.i1(...)
declare void @llvm.coro.suspend.retcon.isVoid(...)
declare i1 @llvm.coro.end(ptr, i1, token)
declare ptr @llvm.coro.prepare.retcon(ptr)
declare token @llvm.coro.alloca.alloc.i32(i32, i32)
declare ptr @llvm.coro.alloca.get(token)
declare void @llvm.coro.alloca.free(token)

declare noalias ptr @allocate(i32 %size)
declare void @deallocate(ptr %ptr)

declare void @print(i32)
declare void @use(ptr)
