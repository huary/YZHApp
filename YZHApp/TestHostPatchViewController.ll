; ModuleID = 'TestHostPatchViewController.m'
source_filename = "TestHostPatchViewController.m"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-ios10.0.0"

%0 = type opaque
%1 = type opaque
%struct._objc_cache = type opaque
%struct._class_t = type { %struct._class_t*, %struct._class_t*, %struct._objc_cache*, i8* (i8*, i8*)**, %struct._class_ro_t* }
%struct._class_ro_t = type { i32, i32, i32, i8*, i8*, %struct.__method_list_t*, %struct._objc_protocol_list*, %struct._ivar_list_t*, i8*, %struct._prop_list_t* }
%struct.__method_list_t = type { i32, i32, [0 x %struct._objc_method] }
%struct._objc_method = type { i8*, i8*, i8* }
%struct._objc_protocol_list = type { i64, [0 x %struct._protocol_t*] }
%struct._protocol_t = type { i8*, i8*, %struct._objc_protocol_list*, %struct.__method_list_t*, %struct.__method_list_t*, %struct.__method_list_t*, %struct.__method_list_t*, %struct._prop_list_t*, i32, i32, i8**, i8*, %struct._prop_list_t* }
%struct._ivar_list_t = type { i32, i32, [0 x %struct._ivar_t] }
%struct._ivar_t = type { i32*, i8*, i8*, i32, i32 }
%struct._prop_list_t = type { i32, i32, [0 x %struct._prop_t] }
%struct._prop_t = type { i8*, i8* }
%struct.CGNode = type { i8, i8, i16, i32, i64, float, double }
%struct._objc_super = type { i8*, i8* }

@_objc_empty_cache = external global %struct._objc_cache
@"OBJC_METACLASS_$_NSObject" = external global %struct._class_t
@OBJC_CLASS_NAME_ = private unnamed_addr constant [7 x i8] c"OCTest\00", section "__TEXT,__objc_classname,cstring_literals", align 1
@"_OBJC_METACLASS_RO_$_OCTest" = internal global %struct._class_ro_t { i32 129, i32 40, i32 40, i8* null, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @OBJC_CLASS_NAME_, i32 0, i32 0), %struct.__method_list_t* null, %struct._objc_protocol_list* null, %struct._ivar_list_t* null, i8* null, %struct._prop_list_t* null }, section "__DATA, __objc_const", align 8
@"OBJC_METACLASS_$_OCTest" = dso_local global %struct._class_t { %struct._class_t* @"OBJC_METACLASS_$_NSObject", %struct._class_t* @"OBJC_METACLASS_$_NSObject", %struct._objc_cache* @_objc_empty_cache, i8* (i8*, i8*)** null, %struct._class_ro_t* @"_OBJC_METACLASS_RO_$_OCTest" }, section "__DATA, __objc_data", align 8
@"OBJC_CLASS_$_NSObject" = external global %struct._class_t
@OBJC_METH_VAR_NAME_ = private unnamed_addr constant [12 x i8] c"testCGNode:\00", section "__TEXT,__objc_methname,cstring_literals", align 1
@OBJC_METH_VAR_TYPE_ = private unnamed_addr constant [41 x i8] c"{CGNode=Bcsiqfd}48@0:8{CGNode=Bcsiqfd}16\00", section "__TEXT,__objc_methtype,cstring_literals", align 1
@"_OBJC_$_INSTANCE_METHODS_OCTest" = internal global { i32, i32, [1 x %struct._objc_method] } { i32 24, i32 1, [1 x %struct._objc_method] [%struct._objc_method { i8* getelementptr inbounds ([12 x i8], [12 x i8]* @OBJC_METH_VAR_NAME_, i32 0, i32 0), i8* getelementptr inbounds ([41 x i8], [41 x i8]* @OBJC_METH_VAR_TYPE_, i32 0, i32 0), i8* bitcast (void (%struct.CGNode*, %0*, i8*, %struct.CGNode*)* @"\01-[OCTest testCGNode:]" to i8*) }] }, section "__DATA, __objc_const", align 8
@"_OBJC_CLASS_RO_$_OCTest" = internal global %struct._class_ro_t { i32 128, i32 8, i32 8, i8* null, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @OBJC_CLASS_NAME_, i32 0, i32 0), %struct.__method_list_t* bitcast ({ i32, i32, [1 x %struct._objc_method] }* @"_OBJC_$_INSTANCE_METHODS_OCTest" to %struct.__method_list_t*), %struct._objc_protocol_list* null, %struct._ivar_list_t* null, i8* null, %struct._prop_list_t* null }, section "__DATA, __objc_const", align 8
@"OBJC_CLASS_$_OCTest" = dso_local global %struct._class_t { %struct._class_t* @"OBJC_METACLASS_$_OCTest", %struct._class_t* @"OBJC_CLASS_$_NSObject", %struct._objc_cache* @_objc_empty_cache, i8* (i8*, i8*)** null, %struct._class_ro_t* @"_OBJC_CLASS_RO_$_OCTest" }, section "__DATA, __objc_data", align 8
@"OBJC_CLASS_$_TestHostPatchViewController" = dso_local global %struct._class_t { %struct._class_t* @"OBJC_METACLASS_$_TestHostPatchViewController", %struct._class_t* @"OBJC_CLASS_$_UIViewController", %struct._objc_cache* @_objc_empty_cache, i8* (i8*, i8*)** null, %struct._class_ro_t* @"_OBJC_CLASS_RO_$_TestHostPatchViewController" }, section "__DATA, __objc_data", align 8
@"OBJC_CLASSLIST_SUP_REFS_$_" = private global %struct._class_t* @"OBJC_CLASS_$_TestHostPatchViewController", section "__DATA,__objc_superrefs,regular,no_dead_strip", align 8
@OBJC_METH_VAR_NAME_.1 = private unnamed_addr constant [12 x i8] c"viewDidLoad\00", section "__TEXT,__objc_methname,cstring_literals", align 1
@OBJC_SELECTOR_REFERENCES_ = internal externally_initialized global i8* getelementptr inbounds ([12 x i8], [12 x i8]* @OBJC_METH_VAR_NAME_.1, i64 0, i64 0), section "__DATA,__objc_selrefs,literal_pointers,no_dead_strip", align 8
@"OBJC_CLASSLIST_REFERENCES_$_" = internal global %struct._class_t* @"OBJC_CLASS_$_OCTest", section "__DATA,__objc_classrefs,regular,no_dead_strip", align 8
@OBJC_METH_VAR_NAME_.2 = private unnamed_addr constant [4 x i8] c"new\00", section "__TEXT,__objc_methname,cstring_literals", align 1
@OBJC_SELECTOR_REFERENCES_.3 = internal externally_initialized global i8* getelementptr inbounds ([4 x i8], [4 x i8]* @OBJC_METH_VAR_NAME_.2, i64 0, i64 0), section "__DATA,__objc_selrefs,literal_pointers,no_dead_strip", align 8
@OBJC_SELECTOR_REFERENCES_.4 = internal externally_initialized global i8* getelementptr inbounds ([12 x i8], [12 x i8]* @OBJC_METH_VAR_NAME_, i64 0, i64 0), section "__DATA,__objc_selrefs,literal_pointers,no_dead_strip", align 8
@"OBJC_METACLASS_$_UIViewController" = external global %struct._class_t
@OBJC_CLASS_NAME_.5 = private unnamed_addr constant [28 x i8] c"TestHostPatchViewController\00", section "__TEXT,__objc_classname,cstring_literals", align 1
@"_OBJC_METACLASS_RO_$_TestHostPatchViewController" = internal global %struct._class_ro_t { i32 129, i32 40, i32 40, i8* null, i8* getelementptr inbounds ([28 x i8], [28 x i8]* @OBJC_CLASS_NAME_.5, i32 0, i32 0), %struct.__method_list_t* null, %struct._objc_protocol_list* null, %struct._ivar_list_t* null, i8* null, %struct._prop_list_t* null }, section "__DATA, __objc_const", align 8
@"OBJC_METACLASS_$_TestHostPatchViewController" = dso_local global %struct._class_t { %struct._class_t* @"OBJC_METACLASS_$_NSObject", %struct._class_t* @"OBJC_METACLASS_$_UIViewController", %struct._objc_cache* @_objc_empty_cache, i8* (i8*, i8*)** null, %struct._class_ro_t* @"_OBJC_METACLASS_RO_$_TestHostPatchViewController" }, section "__DATA, __objc_data", align 8
@"OBJC_CLASS_$_UIViewController" = external global %struct._class_t
@OBJC_METH_VAR_TYPE_.6 = private unnamed_addr constant [8 x i8] c"v16@0:8\00", section "__TEXT,__objc_methtype,cstring_literals", align 1
@OBJC_METH_VAR_NAME_.7 = private unnamed_addr constant [14 x i8] c"pri_testPatch\00", section "__TEXT,__objc_methname,cstring_literals", align 1
@"_OBJC_$_INSTANCE_METHODS_TestHostPatchViewController" = internal global { i32, i32, [2 x %struct._objc_method] } { i32 24, i32 2, [2 x %struct._objc_method] [%struct._objc_method { i8* getelementptr inbounds ([12 x i8], [12 x i8]* @OBJC_METH_VAR_NAME_.1, i32 0, i32 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @OBJC_METH_VAR_TYPE_.6, i32 0, i32 0), i8* bitcast (void (%1*, i8*)* @"\01-[TestHostPatchViewController viewDidLoad]" to i8*) }, %struct._objc_method { i8* getelementptr inbounds ([14 x i8], [14 x i8]* @OBJC_METH_VAR_NAME_.7, i32 0, i32 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @OBJC_METH_VAR_TYPE_.6, i32 0, i32 0), i8* bitcast (void (%1*, i8*)* @"\01-[TestHostPatchViewController pri_testPatch]" to i8*) }] }, section "__DATA, __objc_const", align 8
@"_OBJC_CLASS_RO_$_TestHostPatchViewController" = internal global %struct._class_ro_t { i32 128, i32 8, i32 8, i8* null, i8* getelementptr inbounds ([28 x i8], [28 x i8]* @OBJC_CLASS_NAME_.5, i32 0, i32 0), %struct.__method_list_t* bitcast ({ i32, i32, [2 x %struct._objc_method] }* @"_OBJC_$_INSTANCE_METHODS_TestHostPatchViewController" to %struct.__method_list_t*), %struct._objc_protocol_list* null, %struct._ivar_list_t* null, i8* null, %struct._prop_list_t* null }, section "__DATA, __objc_const", align 8
@"OBJC_LABEL_CLASS_$" = private global [2 x i8*] [i8* bitcast (%struct._class_t* @"OBJC_CLASS_$_OCTest" to i8*), i8* bitcast (%struct._class_t* @"OBJC_CLASS_$_TestHostPatchViewController" to i8*)], section "__DATA,__objc_classlist,regular,no_dead_strip", align 8
@llvm.compiler.used = appending global [16 x i8*] [i8* bitcast (%struct._class_t** @"OBJC_CLASSLIST_REFERENCES_$_" to i8*), i8* bitcast (%struct._class_t** @"OBJC_CLASSLIST_SUP_REFS_$_" to i8*), i8* getelementptr inbounds ([7 x i8], [7 x i8]* @OBJC_CLASS_NAME_, i32 0, i32 0), i8* getelementptr inbounds ([28 x i8], [28 x i8]* @OBJC_CLASS_NAME_.5, i32 0, i32 0), i8* bitcast ([2 x i8*]* @"OBJC_LABEL_CLASS_$" to i8*), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @OBJC_METH_VAR_NAME_, i32 0, i32 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @OBJC_METH_VAR_NAME_.1, i32 0, i32 0), i8* getelementptr inbounds ([4 x i8], [4 x i8]* @OBJC_METH_VAR_NAME_.2, i32 0, i32 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @OBJC_METH_VAR_NAME_.7, i32 0, i32 0), i8* getelementptr inbounds ([41 x i8], [41 x i8]* @OBJC_METH_VAR_TYPE_, i32 0, i32 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @OBJC_METH_VAR_TYPE_.6, i32 0, i32 0), i8* bitcast (i8** @OBJC_SELECTOR_REFERENCES_ to i8*), i8* bitcast (i8** @OBJC_SELECTOR_REFERENCES_.3 to i8*), i8* bitcast (i8** @OBJC_SELECTOR_REFERENCES_.4 to i8*), i8* bitcast ({ i32, i32, [1 x %struct._objc_method] }* @"_OBJC_$_INSTANCE_METHODS_OCTest" to i8*), i8* bitcast ({ i32, i32, [2 x %struct._objc_method] }* @"_OBJC_$_INSTANCE_METHODS_TestHostPatchViewController" to i8*)], section "llvm.metadata"

; Function Attrs: nofree norecurse nounwind optsize ssp uwtable willreturn writeonly
define internal void @"\01-[OCTest testCGNode:]"(%struct.CGNode* noalias nocapture sret(%struct.CGNode) align 8 %0, %0* nocapture readnone %1, i8* nocapture readnone %2, %struct.CGNode* nocapture readnone %3) #0 {
  %5 = getelementptr inbounds %struct.CGNode, %struct.CGNode* %0, i64 0, i32 0
  store i8 0, i8* %5, align 8, !tbaa !13
  %6 = getelementptr inbounds %struct.CGNode, %struct.CGNode* %0, i64 0, i32 1
  store i8 1, i8* %6, align 1, !tbaa !23
  %7 = getelementptr inbounds %struct.CGNode, %struct.CGNode* %0, i64 0, i32 2
  store i16 2, i16* %7, align 2, !tbaa !24
  %8 = getelementptr inbounds %struct.CGNode, %struct.CGNode* %0, i64 0, i32 3
  store i32 3, i32* %8, align 4, !tbaa !25
  %9 = getelementptr inbounds %struct.CGNode, %struct.CGNode* %0, i64 0, i32 4
  store i64 4, i64* %9, align 8, !tbaa !26
  %10 = getelementptr inbounds %struct.CGNode, %struct.CGNode* %0, i64 0, i32 5
  store float 5.000000e+00, float* %10, align 8, !tbaa !27
  %11 = getelementptr inbounds %struct.CGNode, %struct.CGNode* %0, i64 0, i32 6
  store double 6.000000e+00, double* %11, align 8, !tbaa !28
  ret void
}

; Function Attrs: optsize ssp uwtable
define internal void @"\01-[TestHostPatchViewController viewDidLoad]"(%1* %0, i8* nocapture readnone %1) #1 {
  %3 = alloca %struct._objc_super, align 8
  %4 = bitcast %struct._objc_super* %3 to %1**
  store %1* %0, %1** %4, align 8
  %5 = load i8*, i8** bitcast (%struct._class_t** @"OBJC_CLASSLIST_SUP_REFS_$_" to i8**), align 8
  %6 = getelementptr inbounds %struct._objc_super, %struct._objc_super* %3, i64 0, i32 1
  store i8* %5, i8** %6, align 8
  %7 = load i8*, i8** @OBJC_SELECTOR_REFERENCES_, align 8, !invariant.load !29
  call void bitcast (i8* (%struct._objc_super*, i8*, ...)* @objc_msgSendSuper2 to void (%struct._objc_super*, i8*)*)(%struct._objc_super* nonnull %3, i8* %7) #5, !clang.arc.no_objc_arc_exceptions !29
  ret void
}

declare i8* @objc_msgSendSuper2(%struct._objc_super*, i8*, ...) local_unnamed_addr

; Function Attrs: optsize ssp uwtable
define internal void @"\01-[TestHostPatchViewController pri_testPatch]"(%1* nocapture readnone %0, i8* nocapture readnone %1) #1 {
  %3 = alloca %struct.CGNode, align 8
  %4 = alloca %struct.CGNode, align 8
  %5 = alloca %struct.CGNode, align 8
  %6 = load i8*, i8** bitcast (%struct._class_t** @"OBJC_CLASSLIST_REFERENCES_$_" to i8**), align 8
  %7 = load i8*, i8** @OBJC_SELECTOR_REFERENCES_.3, align 8, !invariant.load !29
  %8 = tail call i8* bitcast (i8* (i8*, i8*, ...)* @objc_msgSend to i8* (i8*, i8*)*)(i8* %6, i8* %7) #5, !clang.arc.no_objc_arc_exceptions !29
  %9 = getelementptr inbounds %struct.CGNode, %struct.CGNode* %3, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %9)
  %10 = getelementptr inbounds %struct.CGNode, %struct.CGNode* %4, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %10) #4
  %11 = icmp eq i8* %8, null
  br i1 %11, label %15, label %12

12:                                               ; preds = %2
  %13 = load i8*, i8** @OBJC_SELECTOR_REFERENCES_.4, align 8, !invariant.load !29
  %14 = getelementptr inbounds %struct.CGNode, %struct.CGNode* %5, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 32, i8* nonnull %14) #4
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 8 dereferenceable(32) %14, i8* nonnull align 8 dereferenceable(32) %9, i64 32, i1 false), !tbaa.struct !30
  call void bitcast (i8* (i8*, i8*, ...)* @objc_msgSend to void (%struct.CGNode*, i8*, i8*, %struct.CGNode*)*)(%struct.CGNode* nonnull sret(%struct.CGNode) align 8 %4, i8* nonnull %8, i8* %13, %struct.CGNode* nonnull %5) #5, !clang.arc.no_objc_arc_exceptions !29
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %14) #4
  br label %15

15:                                               ; preds = %2, %12
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %10) #4
  call void @llvm.lifetime.end.p0i8(i64 32, i8* nonnull %9)
  call void @llvm.objc.release(i8* %8) #4, !clang.imprecise_release !29
  ret void
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: nonlazybind
declare i8* @objc_msgSend(i8*, i8*, ...) local_unnamed_addr #3

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: nounwind
declare void @llvm.objc.release(i8*) #4

attributes #0 = { nofree norecurse nounwind optsize ssp uwtable willreturn writeonly "disable-tail-calls"="false" "frame-pointer"="non-leaf" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-a7" "target-features"="+aes,+crypto,+fp-armv8,+neon,+sha2,+zcm,+zcz" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { optsize ssp uwtable "disable-tail-calls"="false" "frame-pointer"="non-leaf" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-a7" "target-features"="+aes,+crypto,+fp-armv8,+neon,+sha2,+zcm,+zcz" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nofree nosync nounwind willreturn }
attributes #3 = { nonlazybind }
attributes #4 = { nounwind }
attributes #5 = { optsize }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9, !10, !11}
!llvm.ident = !{!12}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 14, i32 5]}
!1 = !{i32 1, !"Objective-C Version", i32 2}
!2 = !{i32 1, !"Objective-C Image Info Version", i32 0}
!3 = !{i32 1, !"Objective-C Image Info Section", !"__DATA,__objc_imageinfo,regular,no_dead_strip"}
!4 = !{i32 1, !"Objective-C Garbage Collection", i8 0}
!5 = !{i32 1, !"Objective-C Class Properties", i32 64}
!6 = !{i32 1, !"wchar_size", i32 4}
!7 = !{i32 1, !"branch-target-enforcement", i32 0}
!8 = !{i32 1, !"sign-return-address", i32 0}
!9 = !{i32 1, !"sign-return-address-all", i32 0}
!10 = !{i32 1, !"sign-return-address-with-bkey", i32 0}
!11 = !{i32 7, !"PIC Level", i32 2}
!12 = !{!"Homebrew clang version 12.0.1"}
!13 = !{!14, !15, i64 0}
!14 = !{!"CGNode", !15, i64 0, !16, i64 1, !18, i64 2, !19, i64 4, !20, i64 8, !21, i64 16, !22, i64 24}
!15 = !{!"_Bool", !16, i64 0}
!16 = !{!"omnipotent char", !17, i64 0}
!17 = !{!"Simple C/C++ TBAA"}
!18 = !{!"short", !16, i64 0}
!19 = !{!"int", !16, i64 0}
!20 = !{!"long", !16, i64 0}
!21 = !{!"float", !16, i64 0}
!22 = !{!"double", !16, i64 0}
!23 = !{!14, !16, i64 1}
!24 = !{!14, !18, i64 2}
!25 = !{!14, !19, i64 4}
!26 = !{!14, !20, i64 8}
!27 = !{!14, !21, i64 16}
!28 = !{!14, !22, i64 24}
!29 = !{}
!30 = !{i64 0, i64 1, !31, i64 1, i64 1, !32, i64 2, i64 2, !33, i64 4, i64 4, !34, i64 8, i64 8, !35, i64 16, i64 4, !36, i64 24, i64 8, !37}
!31 = !{!15, !15, i64 0}
!32 = !{!16, !16, i64 0}
!33 = !{!18, !18, i64 0}
!34 = !{!19, !19, i64 0}
!35 = !{!20, !20, i64 0}
!36 = !{!21, !21, i64 0}
!37 = !{!22, !22, i64 0}
