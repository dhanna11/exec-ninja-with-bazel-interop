load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

def _impl(ctx):
    if not ctx.attr.static_library and not ctx.attr.shared_library:
        fail("Either static_library or shared_library must be specified.")

    static_library = None
    shared_library = None
    inputs = ctx.attr.srcs.files.to_list()
    headers = []
    for l in ctx.attr.hdrs:
        files = l.files.to_list()
        inputs += files
        headers += files

    for f in ctx.attr.srcs.files.to_list():
        if ctx.attr.static_library and f.basename == ctx.attr.static_library:
            static_library = f
        if ctx.attr.shared_library and f.basename == ctx.attr.shared_library:
            shared_library = f
    if not static_library and not shared_library:
        fail("Can not find target library file(s) in a filegroup.")

    compilation_info = cc_common.create_compilation_context(
        headers = depset(headers),
        system_includes = depset([]),
        includes = depset([]),
        quote_includes = depset([]),
        defines = depset([]),
    )

    cc_toolchain = find_cpp_toolchain(ctx)

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    library_to_link = cc_common.create_library_to_link(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        static_library = static_library,
        dynamic_library = shared_library,
    )

    linking_info = cc_common.create_linking_context(
        user_link_flags = ctx.attr.linkopts,
        libraries_to_link = [library_to_link],
    )

    cc_info = CcInfo(
        compilation_context = compilation_info,
        linking_context = linking_info,
    )
    deps_cc_info = []
    for dep in ctx.attr.deps:
        if CcInfo in dep:
            deps_cc_info += [dep[CcInfo]]
        else:
            fail("Passed dependency does not provide CcInfo: " + str(dep))
    merged_info = cc_common.merge_cc_infos(cc_infos = [cc_info] + deps_cc_info)

    return [
        merged_info,
        DefaultInfo(files = depset(direct = inputs)),
    ]

cc_import_transitive = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label(allow_files = True),
        "static_library": attr.string(mandatory = False),
        "shared_library": attr.string(mandatory = False),
        "hdrs": attr.label_list(allow_files = True, mandatory = False, default = []),
        "includes": attr.string_list(mandatory = False, default = []),
        "deps": attr.label_list(mandatory = False, default = []),
        "linkopts": attr.string_list(mandatory = False, default = []),
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
    },
    fragments = ["cpp"],
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)
