#!/usr/bin/env python3
"""Generate AltKeeper.xcodeproj/project.pbxproj"""

import os
import uuid

ROOT = os.path.dirname(os.path.abspath(__file__))
PROJECT_NAME = "AltKeeper"
BUNDLE_ID = "com.altkeeper.app"


def gen_id():
    return uuid.uuid4().hex[:24].upper()


def main():
    app_sources = []
    for dirpath, _, filenames in os.walk(f"{ROOT}/{PROJECT_NAME}"):
        for f in sorted(filenames):
            if f.endswith(".swift"):
                rel = os.path.relpath(os.path.join(dirpath, f), ROOT)
                app_sources.append(rel)

    test_sources = [
        f"{PROJECT_NAME}Tests/{f}"
        for f in sorted(os.listdir(f"{ROOT}/{PROJECT_NAME}Tests"))
        if f.endswith(".swift")
    ]

    # IDs
    project_id = gen_id()
    main_group_id = gen_id()
    products_group_id = gen_id()
    app_group_id = gen_id()
    tests_group_id = gen_id()
    resources_group_id = gen_id()
    app_target_id = gen_id()
    test_target_id = gen_id()
    app_product_id = gen_id()
    test_product_id = gen_id()
    sources_phase_app = gen_id()
    resources_phase_app = gen_id()
    frameworks_phase_app = gen_id()
    sources_phase_test = gen_id()
    frameworks_phase_test = gen_id()
    project_config_list = gen_id()
    app_config_list = gen_id()
    test_config_list = gen_id()
    project_debug = gen_id()
    project_release = gen_id()
    app_debug = gen_id()
    app_release = gen_id()
    test_debug = gen_id()
    test_release = gen_id()
    assets_id = gen_id()
    assets_build_id = gen_id()
    info_plist_id = gen_id()
    entitlements_id = gen_id()
    test_dep_id = gen_id()
    test_proxy_id = gen_id()

    model_group = gen_id()
    service_group = gen_id()
    vm_group = gen_id()
    view_group = gen_id()
    util_group = gen_id()
    dashboard_group = gen_id()
    accounts_group = gen_id()
    settings_group = gen_id()
    components_group = gen_id()

    file_refs = {}
    build_files_app = {}
    build_files_test = {}

    for src in app_sources:
        file_refs[src] = gen_id()
        build_files_app[src] = gen_id()
    for src in test_sources:
        file_refs[src] = gen_id()
        build_files_test[src] = gen_id()

    def group_for(path):
        # Order matters: ViewModels contains the substring "Models/"
        if "/ViewModels/" in f"/{path}":
            return vm_group
        if "/Models/" in f"/{path}":
            return model_group
        if "/Services/" in f"/{path}":
            return service_group
        if "/Utilities/" in f"/{path}":
            return util_group
        if "/Dashboard/" in f"/{path}":
            return dashboard_group
        if "/Accounts/" in f"/{path}":
            return accounts_group
        if "/Settings/" in f"/{path}":
            return settings_group
        if "/Components/" in f"/{path}":
            return components_group
        if "/Views/" in f"/{path}":
            return view_group
        return app_group_id

    groups = {
        main_group_id: [app_group_id, tests_group_id, products_group_id],
        products_group_id: [app_product_id, test_product_id],
        app_group_id: [model_group, service_group, vm_group, view_group, util_group, resources_group_id, entitlements_id],
        tests_group_id: [file_refs[s] for s in test_sources],
        resources_group_id: [assets_id, info_plist_id],
        model_group: [],
        service_group: [],
        vm_group: [],
        view_group: [dashboard_group, accounts_group, settings_group, components_group],
        util_group: [],
        dashboard_group: [],
        accounts_group: [],
        settings_group: [],
        components_group: [],
    }

    group_paths = {
        app_group_id: PROJECT_NAME,
        tests_group_id: f"{PROJECT_NAME}Tests",
        resources_group_id: "Resources",
        model_group: "Models",
        service_group: "Services",
        vm_group: "ViewModels",
        view_group: "Views",
        util_group: "Utilities",
        dashboard_group: "Dashboard",
        accounts_group: "Accounts",
        settings_group: "Settings",
        components_group: "Components",
    }

    group_names = {
        products_group_id: "Products",
        app_group_id: PROJECT_NAME,
        tests_group_id: f"{PROJECT_NAME}Tests",
        resources_group_id: "Resources",
        model_group: "Models",
        service_group: "Services",
        vm_group: "ViewModels",
        view_group: "Views",
        util_group: "Utilities",
        dashboard_group: "Dashboard",
        accounts_group: "Accounts",
        settings_group: "Settings",
        components_group: "Components",
    }

    for src in app_sources:
        if src.endswith("AltKeeperApp.swift"):
            groups[app_group_id].insert(0, file_refs[src])
        else:
            groups[group_for(src)].append(file_refs[src])

    o = []
    o.append("// !$*UTF8*$!")
    o.append("{")
    o.append("\tarchiveVersion = 1;")
    o.append("\tclasses = {};")
    o.append("\tobjectVersion = 56;")
    o.append("\tobjects = {")

    o.append("\n/* Begin PBXBuildFile section */")
    for src, bid in build_files_app.items():
        base = os.path.basename(src)
        o.append(f"\t\t{bid} /* {base} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[src]} /* {base} */; }};")
    for src, bid in build_files_test.items():
        base = os.path.basename(src)
        o.append(f"\t\t{bid} /* {base} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[src]} /* {base} */; }};")
    o.append(f"\t\t{assets_build_id} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_id} /* Assets.xcassets */; }};")
    o.append("/* End PBXBuildFile section */")

    o.append("\n/* Begin PBXContainerItemProxy section */")
    o.append(f"\t\t{test_proxy_id} /* PBXContainerItemProxy */ = {{isa = PBXContainerItemProxy; containerPortal = {project_id}; proxyType = 1; remoteGlobalIDString = {app_target_id}; remoteInfo = {PROJECT_NAME}; }};")
    o.append("/* End PBXContainerItemProxy section */")

    o.append("\n/* Begin PBXFileReference section */")
    o.append(f"\t\t{app_product_id} /* {PROJECT_NAME}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
    o.append(f"\t\t{test_product_id} /* {PROJECT_NAME}Tests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = {PROJECT_NAME}Tests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};")
    for src in app_sources + test_sources:
        base = os.path.basename(src)
        o.append(f"\t\t{file_refs[src]} /* {base} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {base}; sourceTree = \"<group>\"; }};")
    o.append(f"\t\t{assets_id} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};")
    o.append(f"\t\t{info_plist_id} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};")
    o.append(f"\t\t{entitlements_id} /* AltKeeper.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = AltKeeper.entitlements; sourceTree = \"<group>\"; }};")
    o.append("/* End PBXFileReference section */")

    o.append("\n/* Begin PBXFrameworksBuildPhase section */")
    o.append(f"\t\t{frameworks_phase_app} /* Frameworks */ = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};")
    o.append(f"\t\t{frameworks_phase_test} /* Frameworks */ = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};")
    o.append("/* End PBXFrameworksBuildPhase section */")

    o.append("\n/* Begin PBXGroup section */")
    for gid, children in groups.items():
        name = group_names.get(gid, "")
        path = group_paths.get(gid)
        child_str = ", ".join(children) if children else ""
        if path:
            label = name or "Main"
            o.append(f"\t\t{gid} /* {label} */ = {{isa = PBXGroup; children = ({child_str}); path = {path}; sourceTree = \"<group>\"; }};")
        else:
            label = name or "Main"
            o.append(f"\t\t{gid} /* {label} */ = {{isa = PBXGroup; children = ({child_str}); sourceTree = \"<group>\"; }};")
    o.append("/* End PBXGroup section */")

    o.append("\n/* Begin PBXNativeTarget section */")
    o.append(f"\t\t{app_target_id} /* {PROJECT_NAME} */ = {{isa = PBXNativeTarget; buildConfigurationList = {app_config_list}; buildPhases = ({sources_phase_app}, {resources_phase_app}, {frameworks_phase_app}); buildRules = (); dependencies = (); name = {PROJECT_NAME}; productName = {PROJECT_NAME}; productReference = {app_product_id}; productType = \"com.apple.product-type.application\"; }};")
    o.append(f"\t\t{test_target_id} /* {PROJECT_NAME}Tests */ = {{isa = PBXNativeTarget; buildConfigurationList = {test_config_list}; buildPhases = ({sources_phase_test}, {frameworks_phase_test}); buildRules = (); dependencies = ({test_dep_id}); name = {PROJECT_NAME}Tests; productName = {PROJECT_NAME}Tests; productReference = {test_product_id}; productType = \"com.apple.product-type.bundle.unit-test\"; }};")
    o.append("/* End PBXNativeTarget section */")

    o.append("\n/* Begin PBXProject section */")
    o.append(f"\t\t{project_id} /* Project object */ = {{isa = PBXProject; attributes = {{BuildIndependentTargetsInParallel = 1; LastSwiftUpdateCheck = 1600; LastUpgradeCheck = 1600; TargetAttributes = {{{test_target_id} = {{CreatedOnToolsVersion = 16.0; TestTargetID = {app_target_id}; }}; }}; }}; buildConfigurationList = {project_config_list}; compatibilityVersion = \"Xcode 14.0\"; developmentRegion = nl; hasScannedForEncodings = 0; knownRegions = (nl, en, Base); mainGroup = {main_group_id}; productRefGroup = {products_group_id}; projectDirPath = \"\"; projectRoot = \"\"; targets = ({app_target_id}, {test_target_id}); }};")
    o.append("/* End PBXProject section */")

    o.append("\n/* Begin PBXResourcesBuildPhase section */")
    o.append(f"\t\t{resources_phase_app} /* Resources */ = {{isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ({assets_build_id} /* Assets.xcassets in Resources */); runOnlyForDeploymentPostprocessing = 0; }};")
    o.append("/* End PBXResourcesBuildPhase section */")

    o.append("\n/* Begin PBXSourcesBuildPhase section */")
    app_files = ", ".join(f"{build_files_app[s]} /* {os.path.basename(s)} in Sources */" for s in app_sources)
    test_files = ", ".join(f"{build_files_test[s]} /* {os.path.basename(s)} in Sources */" for s in test_sources)
    o.append(f"\t\t{sources_phase_app} /* Sources */ = {{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({app_files}); runOnlyForDeploymentPostprocessing = 0; }};")
    o.append(f"\t\t{sources_phase_test} /* Sources */ = {{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({test_files}); runOnlyForDeploymentPostprocessing = 0; }};")
    o.append("/* End PBXSourcesBuildPhase section */")

    o.append("\n/* Begin PBXTargetDependency section */")
    o.append(f"\t\t{test_dep_id} /* PBXTargetDependency */ = {{isa = PBXTargetDependency; target = {app_target_id}; targetProxy = {test_proxy_id}; }};")
    o.append("/* End PBXTargetDependency section */")

    o.append("\n/* Begin XCBuildConfiguration section */")
    for cfg_id, name, is_test in [
        (project_debug, "Debug", False),
        (project_release, "Release", False),
        (app_debug, "Debug", False),
        (app_release, "Release", False),
        (test_debug, "Debug", True),
        (test_release, "Release", True),
    ]:
        if cfg_id in (project_debug, project_release):
            o.append(f"\t\t{cfg_id} /* {name} */ = {{isa = XCBuildConfiguration; buildSettings = {{ALWAYS_SEARCH_USER_PATHS = NO; CLANG_ENABLE_MODULES = YES; CLANG_ENABLE_OBJC_ARC = YES; COPY_PHASE_STRIP = NO; DEBUG_INFORMATION_FORMAT = dwarf; ENABLE_TESTABILITY = YES; GCC_DYNAMIC_NO_PIC = NO; GCC_OPTIMIZATION_LEVEL = 0; IPHONEOS_DEPLOYMENT_TARGET = 18.0; ONLY_ACTIVE_ARCH = YES; SDKROOT = iphoneos; SWIFT_ACTIVE_COMPILATION_CONDITIONS = \"DEBUG $(inherited)\"; SWIFT_OPTIMIZATION_LEVEL = \"-Onone\"; SWIFT_VERSION = 5.0; }}; name = {name}; }};")
        elif is_test:
            o.append(f"\t\t{cfg_id} /* {name} */ = {{isa = XCBuildConfiguration; buildSettings = {{BUNDLE_LOADER = \"$(TEST_HOST)\"; CODE_SIGN_STYLE = Automatic; CURRENT_PROJECT_VERSION = 1; GENERATE_INFOPLIST_FILE = YES; IPHONEOS_DEPLOYMENT_TARGET = 18.0; MARKETING_VERSION = 1.0; PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID}.tests; PRODUCT_NAME = \"$(TARGET_NAME)\"; SWIFT_EMIT_LOC_STRINGS = NO; SWIFT_VERSION = 5.0; TARGETED_DEVICE_FAMILY = \"1,2\"; TEST_HOST = \"$(BUILT_PRODUCTS_DIR)/{PROJECT_NAME}.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/{PROJECT_NAME}\"; }}; name = {name}; }};")
        else:
            debug_extra = "DEBUG_INFORMATION_FORMAT = dwarf;" if name == "Debug" else "DEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\"; SWIFT_COMPILATION_MODE = wholemodule;"
            o.append(f"\t\t{cfg_id} /* {name} */ = {{isa = XCBuildConfiguration; buildSettings = {{ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon; ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor; CODE_SIGN_ENTITLEMENTS = {PROJECT_NAME}/{PROJECT_NAME}.entitlements; CODE_SIGN_STYLE = Automatic; CURRENT_PROJECT_VERSION = 1; DEVELOPMENT_TEAM = \"\"; ENABLE_PREVIEWS = YES; GENERATE_INFOPLIST_FILE = NO; INFOPLIST_FILE = {PROJECT_NAME}/Resources/Info.plist; INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES; INFOPLIST_KEY_UILaunchScreen_Generation = YES; IPHONEOS_DEPLOYMENT_TARGET = 18.0; LD_RUNPATH_SEARCH_PATHS = (\"$(inherited)\", \"@executable_path/Frameworks\"); MARKETING_VERSION = 1.0; PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID}; PRODUCT_NAME = \"$(TARGET_NAME)\"; SWIFT_EMIT_LOC_STRINGS = YES; SWIFT_VERSION = 5.0; TARGETED_DEVICE_FAMILY = \"1,2\"; {debug_extra} }}; name = {name}; }};")
    o.append("/* End XCBuildConfiguration section */")

    o.append("\n/* Begin XCConfigurationList section */")
    o.append(f"\t\t{project_config_list} /* Build configuration list for PBXProject */ = {{isa = XCConfigurationList; buildConfigurations = ({project_debug} /* Debug */, {project_release} /* Release */); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")
    o.append(f"\t\t{app_config_list} /* Build configuration list for PBXNativeTarget {PROJECT_NAME} */ = {{isa = XCConfigurationList; buildConfigurations = ({app_debug} /* Debug */, {app_release} /* Release */); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")
    o.append(f"\t\t{test_config_list} /* Build configuration list for PBXNativeTarget {PROJECT_NAME}Tests */ = {{isa = XCConfigurationList; buildConfigurations = ({test_debug} /* Debug */, {test_release} /* Release */); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")
    o.append("/* End XCConfigurationList section */")

    o.append("\t};")
    o.append(f"\trootObject = {project_id} /* Project object */;")
    o.append("}")

    os.makedirs(f"{ROOT}/{PROJECT_NAME}.xcodeproj", exist_ok=True)
    with open(f"{ROOT}/{PROJECT_NAME}.xcodeproj/project.pbxproj", "w") as f:
        f.write("\n".join(o) + "\n")

    # Scheme
    scheme_dir = f"{ROOT}/{PROJECT_NAME}.xcodeproj/xcshareddata/xcschemes"
    os.makedirs(scheme_dir, exist_ok=True)
    scheme = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{app_target_id}"
               BuildableName = "{PROJECT_NAME}.app"
               BlueprintName = "{PROJECT_NAME}"
               ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{test_target_id}"
               BuildableName = "{PROJECT_NAME}Tests.xctest"
               BlueprintName = "{PROJECT_NAME}Tests"
               ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_id}"
            BuildableName = "{PROJECT_NAME}.app"
            BlueprintName = "{PROJECT_NAME}"
            ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_id}"
            BuildableName = "{PROJECT_NAME}.app"
            BlueprintName = "{PROJECT_NAME}"
            ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""
    with open(f"{scheme_dir}/{PROJECT_NAME}.xcscheme", "w") as f:
        f.write(scheme)

    print(f"Generated {PROJECT_NAME}.xcodeproj with {len(app_sources)} source files and {len(test_sources)} test files")


if __name__ == "__main__":
    main()
