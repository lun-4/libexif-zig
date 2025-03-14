const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const config_h = b.addConfigHeader(.{
        .style = .{ .autoconf = b.path("src/config.h.in") },
        .include_path = "config.h",
    }, .{
        .ENABLE_NLS = 1,
        .HAVE_CFLOCALECOPYCURRENT = null,
        .HAVE_CFPREFERENCESCOPYAPPVALUE = null,
        .HAVE_DCGETTEXT = 1,
        .HAVE_DLFCN_H = 1,
        .HAVE_GETTEXT = 1,
        .HAVE_ICONV = 1,
        .HAVE_INTTYPES_H = 1,
        .HAVE_LOCALTIME_R = 1,
        .HAVE_LOCALTIME_S = null,
        .HAVE_STDINT_H = 1,
        .HAVE_STDIO_H = 1,
        .HAVE_STDLIB_H = 1,
        .HAVE_STRINGS_H = 1,
        .HAVE_STRING_H = 1,
        .HAVE_SYS_STAT_H = 1,
        .HAVE_SYS_TYPES_H = 1,
        .HAVE_UNISTD_H = 1,
        .ICONV_CONST = 1,
        .LT_OBJDIR = ".libs/",
        .PACKAGE = "libexif",
        .PACKAGE_BUGREPORT = "libexif-devel@lists.sourceforge.net",
        .PACKAGE_NAME = "EXIF library",
        .PACKAGE_STRING = "EXIF library 0.6.24.1",
        .PACKAGE_TARNAME = "libexif",
        .PACKAGE_URL = "https://libexif.github.io/",
        .PACKAGE_VERSION = "0.6.24.1",
        .STDC_HEADERS = 1,
        .VERSION = "0.6.24.1",
        ._FILE_OFFSET_BITS = null,
        ._LARGE_FILES = null,
        ._TIME_BITS = null,
        .__MINGW_USE_VC2005_COMPAT = null,
        .@"inline" = null,
    });

    const libexif_dep = b.dependency("libexif", .{});

    const lib = b.addStaticLibrary(.{
        .name = "exif",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.root_module.addCMacro("LOCALEDIR", "\"/usr/share/locale\"");
    lib.root_module.addCMacro("GETTEXT_PACKAGE", "\"libexif\"");
    lib.addConfigHeader(config_h);
    lib.addCSourceFiles(.{
        .root = libexif_dep.path("libexif"),
        .files = &libexif_src,
    });
    lib.addCSourceFiles(.{
        .root = libexif_dep.path("libexif/canon"),
        .files = &libcanon_src,
    });
    lib.addCSourceFiles(.{
        .root = libexif_dep.path("libexif/fuji"),
        .files = &libfuji_src,
    });
    lib.addCSourceFiles(.{
        .root = libexif_dep.path("libexif/olympus"),
        .files = &libolympus_src,
    });
    lib.addCSourceFiles(.{
        .root = libexif_dep.path("libexif/pentax"),
        .files = &libpentax_src,
    });
    lib.addIncludePath(b.path("src"));
    lib.addIncludePath(libexif_dep.path("."));
    lib.addIncludePath(libexif_dep.path("libexif/canon"));
    lib.addIncludePath(libexif_dep.path("libexif/fuji"));
    lib.addIncludePath(libexif_dep.path("libexif/olympus"));
    lib.addIncludePath(libexif_dep.path("libexif/pentax"));
    lib.installHeadersDirectory(b.path("src"), "", .{
        .include_extensions = &.{".h"},
    });
    lib.installHeadersDirectory(libexif_dep.path("."), "", .{
        .include_extensions = &.{".h"},
    });
    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

const libexif_src = [_][]const u8{
    "exif-byte-order.c",
    "exif-content.c",
    "exif-data.c",
    "exif-entry.c",
    "exif-format.c",
    "exif-gps-ifd.c",
    "exif-ifd.c",
    "exif-loader.c",
    "exif-log.c",
    "exif-mem.c",
    "exif-mnote-data.c",
    "exif-tag.c",
    "exif-utils.c",
};

const libcanon_src = [_][]const u8{
    "exif-mnote-data-canon.c",
    "mnote-canon-entry.c",
    "mnote-canon-tag.c",
};

const libfuji_src = [_][]const u8{
    "exif-mnote-data-fuji.c",
    "mnote-fuji-entry.c",
    "mnote-fuji-tag.c",
};

const libolympus_src = [_][]const u8{
    "exif-mnote-data-olympus.c",
    "mnote-olympus-entry.c",
    "mnote-olympus-tag.c",
};

const libpentax_src = [_][]const u8{
    "exif-mnote-data-pentax.c",
    "mnote-pentax-entry.c",
    "mnote-pentax-tag.c",
};
