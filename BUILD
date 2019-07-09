load(":cc_import_transitive.bzl", "cc_import_transitive")

ninja_sources = [
    "call_fun_c.cxx",
    "fun_a.cxx",
    "fun_a.h",
    "fun_b.h",
    "fun_c.cxx",
    "fun_c.h",
]

ninja_build(
    name = "fun_a",
    srcs = ninja_sources,
    build_ninja = ":build.ninja",
    export_targets = {"lib/fun_a.a": "fun_a.a"},
)

filegroup(
    name = "fun_a_srcs",
    srcs = [":fun_a"],
    output_group = "fun_a.a",
)

cc_import_transitive(
    name = "import_a",
    srcs = ":fun_a_srcs",
    hdrs = ["fun_a.h"],
    static_library = "fun_a.a",
)

ninja_build(
    name = "fun_a_so",
    srcs = ninja_sources,
    build_ninja = ":build.ninja",
    export_targets = {"lib/libfun_a.so": "libfun_a.so"},
)

filegroup(
    name = "fun_a_so_srcs",
    srcs = [":fun_a_so"],
    output_group = "libfun_a.so",
)

cc_import_transitive(
    name = "import_a_so",
    srcs = ":fun_a_so_srcs",
    hdrs = ["fun_a.h"],
    shared_library = "libfun_a.so",
)

cc_library(
    name = "fun_b",
    srcs = ["fun_b.cxx"],
    hdrs = ["fun_b.h"],
    deps = [":import_a"],
)

cc_library(
    name = "fun_b_so",
    srcs = ["fun_b.cxx"],
    hdrs = ["fun_b.h"],
    deps = [":import_a_so"],
    linkstatic = False,
    linkopts = ["-lstdc++"],
    copts = ["-fPIC"],
)

ninja_build(
    name = "fun_c",
    srcs = ninja_sources,
    build_ninja = ":build.ninja",
    deps_mapping = {
        ":fun_b": "libfun_b.a",
        ":import_a": "fun_a.a",
    },
    export_targets = {"lib/fun_c.a": "fun_c.a"},
)

filegroup(
    name = "fun_c_srcs",
    srcs = [":fun_c"],
    output_group = "fun_c.a",
)

cc_import_transitive(
    name = "import_c",
    srcs = ":fun_c_srcs",
    hdrs = ["fun_c.h"],
    static_library = "fun_c.a",
    deps = [
        ":fun_b",
        ":import_a",
    ],
)

ninja_build(
    name = "fun_c_so",
    srcs = ninja_sources,
    build_ninja = ":build.ninja",
    deps_mapping = {
        ":fun_b_so": "libfun_b_so.so",
        ":import_a_so": "libfun_a.so",
    },
    export_targets = {"lib/libfun_c.so": "libfun_c.so"},
)

filegroup(
    name = "fun_c_so_srcs",
    srcs = [":fun_c_so"],
    output_group = "libfun_c.so",
)

cc_import_transitive(
    name = "import_c_so",
    srcs = ":fun_c_so_srcs",
    hdrs = ["fun_c.h"],
    shared_library = "libfun_c.so",
    deps = [
        ":fun_b_so",
        ":import_a_so",
    ],
)

cc_binary(
    name = "call_from_bazel",
    srcs = ["call_fun_c.cxx"],
    deps = [
        ":import_c",
    ],
)

ninja_build(
    name = "call_from_ninja",
    srcs = ninja_sources,
    build_ninja = ":build.ninja",
    deps_mapping = {":fun_b": "libfun_b.a"},
    executable_target = "out/hello",
    export_targets = {"out/hello": "hello"},
)

cc_binary(
    name = "call_from_bazel_so",
    srcs = ["call_fun_c.cxx"],
    deps = [
        ":import_c_so",
    ],
    linkstatic = False,
    linkopts = ["--verbose"],
)

ninja_build(
    name = "call_from_ninja_so",
    srcs = ninja_sources,
    build_ninja = ":build.ninja",
    deps_mapping = {
                    ":fun_b_so": "libfun_b_so.so",
                    },
    executable_target = "lib/libcall_fun_c.so",
    export_targets = {"lib/libcall_fun_c.so": "libcall_fun_c.so"},
)

filegroup(
    name = "call_from_ninja_so_sources",
    srcs = [":call_from_ninja_so"],
    output_group = "libcall_fun_c.so",
)

ninja_build(
    name = "hello_shared",
    srcs = ninja_sources,
    build_ninja = ":build.ninja",
    deps_mapping = {
                    ":fun_b_so": "libfun_b_so.so",
                    },
    executable_target = "out/hello_shared",
    export_targets = {"out/hello_shared": "hello_shared"},
)

sh_test(
    name = "test_call_from_bazel",
    srcs = ["test_call.sh"],
    data = ["call_from_bazel",
            ":fun_b",
            ":import_a",
            ":import_c"],
    args = ["$(location call_from_bazel)", "false"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

sh_test(
    name = "test_call_from_bazel_so",
    srcs = ["test_call.sh"],
    data = ["call_from_bazel_so",
            ":fun_b_so",
            ":import_a_so",
            ":import_c_so"],
    args = ["$(location call_from_bazel_so)", "false"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

sh_test(
    name = "test_call_from_ninja",
    srcs = ["test_call.sh"],
    data = ["call_from_ninja",
            ":fun_b",
            ":import_a",
            ":import_c"],
    args = ["$(location call_from_ninja)", "false"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

sh_test(
    name = "test_call_from_ninja_so",
    srcs = ["test_call.sh"],
    data = ["hello_shared",
            ":fun_b_so",
            ":fun_a_so_srcs",
            ":fun_c_so_srcs",
            ":call_from_ninja_so_sources"],
    args = ["$(location hello_shared)", "true"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

test_suite(name = "tests",
           tests = [
               "test_call_from_bazel",
               "test_call_from_bazel_so",
               "test_call_from_ninja",
               "test_call_from_ninja_so"
               ])
