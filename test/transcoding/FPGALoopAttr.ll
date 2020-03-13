; RUN: llvm-as < %s > %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_INTEL_fpga_loop_controls -o - -spirv-text | FileCheck %s --check-prefix=CHECK-SPIRV

; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_INTEL_fpga_loop_controls -o %t.spv
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-LLVM

; RUN: llvm-spirv %t.bc -o - -spirv-text | FileCheck %s --check-prefix=CHECK-SPIRV-NEGATIVE

; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-LLVM-NEGATIVE

; CHECK-SPIRV: 2 Capability FPGALoopControlsINTEL
; CHECK-SPIRV: 9 Extension "SPV_INTEL_fpga_loop_controls"
; CHECK-SPIRV-NEGATIVE-NOT: 2 Capability FPGALoopControlsINTEL
; CHECK-SPIRV-NEGATIVE-NOT: 9 Extension "SPV_INTEL_fpga_loop_controls"

; ModuleID = 'FPGALoopAttr.cl'
source_filename = "FPGALoopAttr.cl"
target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir64-unknown-unknown-unknown"

; CHECK-SPIRV: Function
; Function Attrs: convergent noinline nounwind optnone
define spir_kernel void @test_ivdep() #0 {
entry:
  %a = alloca [10 x i32], align 4
  %i = alloca i32, align 4
  %i1 = alloca i32, align 4
  %i10 = alloca i32, align 4
  %i19 = alloca i32, align 4
  %i28 = alloca i32, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond
; Per SPIR-V spec, LoopControlDependencyInfiniteMask = 0x00000004
; CHECK-SPIRV: 4 LoopMerge {{[0-9]+}} {{[0-9]+}} 4
; CHECK-SPIRV-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
; CHECK-SPIRV-NEGATIVE: 4 LoopMerge {{[0-9]+}} {{[0-9]+}} 4
; CHECK-SPIRV-NEGATIVE-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp ne i32 %0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %arrayidx = getelementptr inbounds [10 x i32], [10 x i32]* %a, i64 0, i64 %idxprom
  store i32 0, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %2 = load i32, i32* %i, align 4
  %inc = add nsw i32 %2, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond, !llvm.loop !3

for.end:                                          ; preds = %for.cond
  store i32 0, i32* %i1, align 4
  br label %for.cond2

; Per SPIR-V spec, LoopControlDependencyLengthMask = 0x00000008
; CHECK-SPIRV: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 8 2
; CHECK-SPIRV-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
; CHECK-SPIRV-NEGATIVE: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 8 2
; CHECK-SPIRV-NEGATIVE-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
for.cond2:                                        ; preds = %for.inc7, %for.end
  %3 = load i32, i32* %i1, align 4
  %cmp3 = icmp ne i32 %3, 10
  br i1 %cmp3, label %for.body4, label %for.end9

for.body4:                                        ; preds = %for.cond2
  %4 = load i32, i32* %i1, align 4
  %idxprom5 = sext i32 %4 to i64
  %arrayidx6 = getelementptr inbounds [10 x i32], [10 x i32]* %a, i64 0, i64 %idxprom5
  store i32 0, i32* %arrayidx6, align 4
  br label %for.inc7

for.inc7:                                         ; preds = %for.body4
  %5 = load i32, i32* %i1, align 4
  %inc8 = add nsw i32 %5, 1
  store i32 %inc8, i32* %i1, align 4
  br label %for.cond2, !llvm.loop !5

for.end9:                                         ; preds = %for.cond2
  store i32 0, i32* %i10, align 4
  br label %for.cond11

; Per SPIR-V spec extension INTEL/SPV_INTEL_fpga_loop_controls,
; LoopControlInitiationIntervalINTEL = 0x10000 (65536)
; CHECK-SPIRV: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 65536 2
; CHECK-SPIRV-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
; CHECK-SPIRV-NEGATIVE-NOT: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 65536 2
for.cond11:                                       ; preds = %for.inc16, %for.end9
  %6 = load i32, i32* %i10, align 4
  %cmp12 = icmp ne i32 %6, 10
  br i1 %cmp12, label %for.body13, label %for.end18

for.body13:                                       ; preds = %for.cond11
  %7 = load i32, i32* %i10, align 4
  %idxprom14 = sext i32 %7 to i64
  %arrayidx15 = getelementptr inbounds [10 x i32], [10 x i32]* %a, i64 0, i64 %idxprom14
  store i32 0, i32* %arrayidx15, align 4
  br label %for.inc16

for.inc16:                                        ; preds = %for.body13
  %8 = load i32, i32* %i10, align 4
  %inc17 = add nsw i32 %8, 1
  store i32 %inc17, i32* %i10, align 4
  br label %for.cond11, !llvm.loop !7

for.end18:                                        ; preds = %for.cond11
  store i32 0, i32* %i19, align 4
  br label %for.cond20

; Per SPIR-V spec extension INTEL/SPV_INTEL_fpga_loop_controls,
; LoopControlMaxConcurrencyINTEL = 0x20000 (131072)
; CHECK-SPIRV: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 131072 2
; CHECK-SPIRV-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
; CHECK-SPIRV-NEGATIVE-NOT: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 131072 2
for.cond20:                                       ; preds = %for.inc25, %for.end18
  %9 = load i32, i32* %i19, align 4
  %cmp21 = icmp ne i32 %9, 10
  br i1 %cmp21, label %for.body22, label %for.end27

for.body22:                                       ; preds = %for.cond20
  %10 = load i32, i32* %i19, align 4
  %idxprom23 = sext i32 %10 to i64
  %arrayidx24 = getelementptr inbounds [10 x i32], [10 x i32]* %a, i64 0, i64 %idxprom23
  store i32 0, i32* %arrayidx24, align 4
  br label %for.inc25

for.inc25:                                        ; preds = %for.body22
  %11 = load i32, i32* %i19, align 4
  %inc26 = add nsw i32 %11, 1
  store i32 %inc26, i32* %i19, align 4
  br label %for.cond20, !llvm.loop !9

for.end27:                                        ; preds = %for.cond20
  store i32 0, i32* %i28, align 4
  br label %for.cond29

; Per SPIR-V spec extension INTEL/SPV_INTEL_fpga_loop_controls,
; LoopControlInitiationIntervalINTEL & LoopControlMaxConcurrencyINTEL = 0x10000 & 0x20000 = 0x30000 (196608)
; CHECK-SPIRV: 6 LoopMerge {{[0-9]+}} {{[0-9]+}} 196608 2 2
; CHECK-SPIRV: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
; CHECK-SPIRV-NEGATIVE-NOT: 6 LoopMerge {{[0-9]+}} {{[0-9]+}} 196608 2 2
for.cond29:                                       ; preds = %for.inc34, %for.end27
  %12 = load i32, i32* %i28, align 4
  %cmp30 = icmp ne i32 %12, 10
  br i1 %cmp30, label %for.body31, label %for.end36

for.body31:                                       ; preds = %for.cond29
  %13 = load i32, i32* %i28, align 4
  %idxprom32 = sext i32 %13 to i64
  %arrayidx33 = getelementptr inbounds [10 x i32], [10 x i32]* %a, i64 0, i64 %idxprom32
  store i32 0, i32* %arrayidx33, align 4
  br label %for.inc34

for.inc34:                                        ; preds = %for.body31
  %14 = load i32, i32* %i28, align 4
  %inc35 = add nsw i32 %14, 1
  store i32 %inc35, i32* %i28, align 4
  br label %for.cond29, !llvm.loop !11

for.end36:                                        ; preds = %for.cond29
  ret void
}

; Function Attrs: noinline nounwind optnone
define spir_func void @loop_pipelining() #0 {
entry:
  %a = alloca [10 x i32], align 4
  %i = alloca i32, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

; Per SPIR-V spec, LoopControlPipelineEnableINTEL = 0x80000 (524288)
; CHECK-SPIRV: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 524288 1
; CHECK-SPIRV-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
; CHECK-SPIRV-NEGATIVE-NOT: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 524288 1
for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp ne i32 %0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %arrayidx = getelementptr inbounds [10 x i32], [10 x i32]* %a, i64 0, i64 %idxprom
  store i32 0, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %2 = load i32, i32* %i, align 4
  %inc = add nsw i32 %2, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond, !llvm.loop !12

for.end:                                          ; preds = %for.cond
  ret void
}

; Function Attrs: noinline nounwind optnone
define spir_func void @loop_coalesce() #0 {
entry:
  %i = alloca i32, align 4
  %m = alloca i32, align 4
  store i32 0, i32* %i, align 4
  store i32 42, i32* %m, align 4
  br label %while.cond

; Per SPIR-V spec, LoopControlLoopCoalesceINTEL = 0x100000 (1048576)
; CHECK-SPIRV: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 1048576 4
; CHECK-SPIRV-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
; CHECK-SPIRV-NEGATIVE-NOT: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 1048576 4
while.cond:                                       ; preds = %if.end, %if.then, %entry
  %0 = load i32, i32* %i, align 4
  %1 = load i32, i32* %m, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %2 = load i32, i32* %i, align 4
  %rem = srem i32 %2, 2
  %tobool = icmp ne i32 %rem, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  %3 = load i32, i32* %i, align 4
  %inc = add nsw i32 %3, 1
  store i32 %inc, i32* %i, align 4
  br label %while.cond, !llvm.loop !14

if.end:                                           ; preds = %while.body
  br label %while.cond, !llvm.loop !14

while.end:                                        ; preds = %while.cond
  store i32 0, i32* %i, align 4
  br label %while.cond1

; Per SPIR-V spec, LoopControlLoopCoalesceINTEL = 0x100000 (1048576)
; CHECK-SPIRV: 4 LoopMerge {{[0-9]+}} {{[0-9]+}} 1048576
; CHECK-SPIRV-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
; CHECK-SPIRV-NEGATIVE-NOT: 4 LoopMerge {{[0-9]+}} {{[0-9]+}} 1048576
while.cond1:                                      ; preds = %if.end8, %if.then6, %while.end
  %4 = load i32, i32* %i, align 4
  %5 = load i32, i32* %m, align 4
  %cmp2 = icmp slt i32 %4, %5
  br i1 %cmp2, label %while.body3, label %while.end9

while.body3:                                      ; preds = %while.cond1
  %6 = load i32, i32* %i, align 4
  %rem4 = srem i32 %6, 3
  %tobool5 = icmp ne i32 %rem4, 0
  br i1 %tobool5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %while.body3
  %7 = load i32, i32* %i, align 4
  %inc7 = add nsw i32 %7, 1
  store i32 %inc7, i32* %i, align 4
  br label %while.cond1, !llvm.loop !16

if.end8:                                          ; preds = %while.body3
  br label %while.cond1, !llvm.loop !16

while.end9:                                       ; preds = %while.cond1
  ret void
}

; Function Attrs: noinline nounwind optnone
define spir_func void @max_interleaving() #0 {
entry:
  %a = alloca [10 x i32], align 4
  %i = alloca i32, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

; Per SPIR-V spec, LoopControlMaxInterleavingINTEL = 0x200000 (2097152)
; CHECK-SPIRV: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 2097152 3
; CHECK-SPIRV-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
; CHECK-SPIRV-NEGATIVE-NOT: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 2097152 3
for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp ne i32 %0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %arrayidx = getelementptr inbounds [10 x i32], [10 x i32]* %a, i64 0, i64 %idxprom
  store i32 0, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %2 = load i32, i32* %i, align 4
  %inc = add nsw i32 %2, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond, !llvm.loop !18

for.end:                                          ; preds = %for.cond
  ret void
}

; Function Attrs: noinline nounwind optnone
define spir_func void @speculated_iterations() #0 {
entry:
  %a = alloca [10 x i32], align 4
  %i = alloca i32, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

; Per SPIR-V spec, LoopControlSpeculatedIterationsINTEL = 0x400000 (4194304)
; CHECK-SPIRV: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 4194304 4
; CHECK-SPIRV-NEXT: 4 BranchConditional {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
; CHECK-SPIRV-NEGATIVE-NOT: 5 LoopMerge {{[0-9]+}} {{[0-9]+}} 4194304 4
for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp ne i32 %0, 10
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %arrayidx = getelementptr inbounds [10 x i32], [10 x i32]* %a, i64 0, i64 %idxprom
  store i32 0, i32* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %2 = load i32, i32* %i, align 4
  %inc = add nsw i32 %2, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond, !llvm.loop !20

for.end:                                          ; preds = %for.cond
  ret void
}

attributes #0 = { convergent noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "denorms-are-zero"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!opencl.enable.FP_CONTRACT = !{}
!opencl.ocl.version = !{!1}
!opencl.spir.version = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, i32 2}
!3 = distinct !{!3, !4}
!4 = !{!"llvm.loop.ivdep.enable"}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.ivdep.safelen", i32 2}
!7 = distinct !{!7, !8}
!8 = !{!"llvm.loop.ii.count", i32 2}
!9 = distinct !{!9, !10}
!10 = !{!"llvm.loop.max_concurrency.count", i32 2}
!11 = distinct !{!11, !8, !10}
!12 = distinct !{!12, !13}
!13 = !{!"llvm.loop.intel.pipelining.enable", i32 1}
!14 = distinct !{!14, !15}
!15 = !{!"llvm.loop.coalesce.count", i32 4}
!16 = distinct !{!16, !17}
!17 = !{!"llvm.loop.coalesce.enable"}
!18 = distinct !{!18, !19}
!19 = !{!"llvm.loop.max_interleaving.count", i32 3}
!20 = distinct !{!20, !21}
!21 = !{!"llvm.loop.intel.speculated.iterations.count", i32 4}

; CHECK-LLVM: br label %for.cond{{[0-9]*}}, !llvm.loop ![[MD_A:[0-9]+]]
; CHECK-LLVM: br label %for.cond{{[0-9]+}}, !llvm.loop ![[MD_B:[0-9]+]]
; CHECK-LLVM: br label %for.cond{{[0-9]+}}, !llvm.loop ![[MD_C:[0-9]+]]
; CHECK-LLVM: br label %for.cond{{[0-9]+}}, !llvm.loop ![[MD_D:[0-9]+]]
; CHECK-LLVM: br label %for.cond{{[0-9]+}}, !llvm.loop ![[MD_E:[0-9]+]]
; CHECK-LLVM: br label %for.cond{{[0-9]*}}, !llvm.loop ![[MD_F:[0-9]+]]
; CHECK-LLVM: br label %while.cond{{[0-9]*}}, !llvm.loop ![[MD_G:[0-9]+]]
; CHECK-LLVM: br label %while.cond{{[0-9]+}}, !llvm.loop ![[MD_H:[0-9]+]]
; CHECK-LLVM: br label %for.cond{{[0-9]*}}, !llvm.loop ![[MD_I:[0-9]+]]
; CHECK-LLVM: br label %for.cond{{[0-9]*}}, !llvm.loop ![[MD_J:[0-9]+]]

; CHECK-LLVM-NEGATIVE: br label %for.cond{{[0-9]*}}, !llvm.loop ![[MD_A:[0-9]+]]
; CHECK-LLVM-NEGATIVE: br label %for.cond{{[0-9]+}}, !llvm.loop ![[MD_B:[0-9]+]]
; CHECK-LLVM-NEGATIVE-NOT: br label %for.cond{{[0-9]+}}, !llvm.loop ![[MD_C:[0-9]+]]
; CHECK-LLVM-NEGATIVE-NOT: br label %for.cond{{[0-9]+}}, !llvm.loop ![[MD_D:[0-9]+]]
; CHECK-LLVM-NEGATIVE-NOT: br label %for.cond{{[0-9]+}}, !llvm.loop ![[MD_E:[0-9]+]]
; CHECK-LLVM-NEGATIVE-NOT: br label %for.cond{{[0-9]*}}, !llvm.loop ![[MD_F:[0-9]+]]
; CHECK-LLVM-NEGATIVE-NOT: br label %while.cond{{[0-9]*}}, !llvm.loop ![[MD_G:[0-9]+]]
; CHECK-LLVM-NEGATIVE-NOT: br label %while.cond{{[0-9]+}}, !llvm.loop ![[MD_H:[0-9]+]]
; CHECK-LLVM-NEGATIVE-NOT: br label %for.cond{{[0-9]*}}, !llvm.loop ![[MD_I:[0-9]+]]
; CHECK-LLVM-NEGATIVE-NOT: br label %for.cond{{[0-9]*}}, !llvm.loop ![[MD_J:[0-9]+]]

; CHECK-LLVM: ![[MD_A]] = distinct !{![[MD_A]], ![[MD_ivdep_enable:[0-9]+]]}
; CHECK-LLVM: ![[MD_ivdep_enable]] = !{!"llvm.loop.ivdep.enable"}
; CHECK-LLVM: ![[MD_B]] = distinct !{![[MD_B]], ![[MD_ivdep:[0-9]+]]}
; CHECK-LLVM: ![[MD_ivdep]] = !{!"llvm.loop.ivdep.safelen", i32 2}
; CHECK-LLVM: ![[MD_C]] = distinct !{![[MD_C]], ![[MD_ii:[0-9]+]]}
; CHECK-LLVM: ![[MD_ii]] = !{!"llvm.loop.ii.count", i32 2}
; CHECK-LLVM: ![[MD_D]] = distinct !{![[MD_D]], ![[MD_max_concurrency:[0-9]+]]}
; CHECK-LLVM: ![[MD_max_concurrency]] = !{!"llvm.loop.max_concurrency.count", i32 2}
; CHECK-LLVM: ![[MD_E]] = distinct !{![[MD_E]], ![[MD_ii:[0-9]+]], ![[MD_max_concurrency:[0-9]+]]}
; CHECK-LLVM: ![[MD_F]] = distinct !{![[MD_F]], ![[MD_pipelining:[0-9]+]]}
; CHECK-LLVM: ![[MD_pipelining]] = !{!"llvm.loop.intel.pipelining.enable", i32 1}
; CHECK-LLVM: ![[MD_G]] = distinct !{![[MD_G]], ![[MD_loop_coalesce_count:[0-9]+]]}
; CHECK-LLVM: ![[MD_loop_coalesce_count]] = !{!"llvm.loop.coalesce.count", i32 4}
; CHECK-LLVM: ![[MD_H]] = distinct !{![[MD_H]], ![[MD_loop_coalesce:[0-9]+]]}
; CHECK-LLVM: ![[MD_loop_coalesce]] = !{![[MD_loop_coalesce_enable:[0-9]+]]}
; CHECK-LLVM: ![[MD_loop_coalesce_enable]] = !{!"llvm.loop.coalesce.enable"}
; CHECK-LLVM: ![[MD_I]] = distinct !{![[MD_I]], ![[MD_max_interleaving:[0-9]+]]}
; CHECK-LLVM: ![[MD_max_interleaving]] = !{!"llvm.loop.max_interleaving.count", i32 3}
; CHECK-LLVM: ![[MD_J]] = distinct !{![[MD_J]], ![[MD_spec_iterations:[0-9]+]]}
; CHECK-LLVM: ![[MD_spec_iterations]] = !{!"llvm.loop.intel.speculated.iterations.count", i32 4}

; CHECK-LLVM-NEGATIVE: ![[MD_A]] = distinct !{![[MD_A]], ![[MD_ivdep_enable:[0-9]+]]}
; CHECK-LLVM-NEGATIVE: ![[MD_ivdep_enable]] = !{!"llvm.loop.ivdep.enable"}
; CHECK-LLVM-NEGATIVE: ![[MD_B]] = distinct !{![[MD_B]], ![[MD_ivdep:[0-9]+]]}
; CHECK-LLVM-NEGATIVE: ![[MD_ivdep]] = !{!"llvm.loop.ivdep.safelen", i32 2}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_C]] = distinct !{![[MD_C]], ![[MD_ii:[0-9]+]]}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_ii]] = !{!"llvm.loop.ii.count", i32 2}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_D]] = distinct !{![[MD_D]], ![[MD_max_concurrency:[0-9]+]]}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_max_concurrency]] = !{!"llvm.loop.max_concurrency.count", i32 2}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_E]] = distinct !{![[MD_E]], ![[MD_ii:[0-9]+]], ![[MD_max_concurrency:[0-9]+]]}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_F]] = distinct !{![[MD_F]], ![[MD_pipelining:[0-9]+]]}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_pipelining]] = !{!"llvm.loop.intel.pipelining.enable", i32 1}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_G]] = distinct !{![[MD_G]], ![[MD_loop_coalesce_count:[0-9]+]]}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_loop_coalesce_count]] = !{!"llvm.loop.coalesce.count", i32 4}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_H]] = distinct !{![[MD_H]], ![[MD_loop_coalesce:[0-9]+]]}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_loop_coalesce]] = !{![[MD_loop_coalesce_enable:[0-9]+]]}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_loop_coalesce_enable]] = !{!"llvm.loop.coalesce.enable"}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_I]] = distinct !{![[MD_I]], ![[MD_max_interleaving:[0-9]+]]}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_max_interleaving]] = !{!"llvm.loop.max_interleaving.count", i32 3}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_J]] = distinct !{![[MD_J]], ![[MD_spec_iterations:[0-9]+]]}
; CHECK-LLVM-NEGATIVE-NOT: ![[MD_spec_iterations]] = !{!"llvm.loop.intel.speculated.iterations.count", i32 4}