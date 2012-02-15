// base for Cpp modules

Module {
    condition: false
    additionalProductFileTags: ["hpp"]  // to include all rules that generate hpp files

    property string warningLevel : 'all' // 'none', 'all'
    property bool treatWarningsAsErrors : false
    property string architecture: qbs.architecture
    property string optimization: qbs.optimization
    property bool debugInformation: qbs.debugInformation
    property string precompiledHeader
    property paths precompiledHeaderDir: [product.buildDirectory]
    property var defines
    property paths includePaths
    property paths libraryPaths
    property paths frameworkPaths
    property var compilerFlags
    property string compilerPath
    // ### same separation in msvc?
    property var dynamicLibraries // list of names, will be linked with -lname
    property var staticLibraries // list of static library files
    property var frameworks // list of frameworks, will be linked with '-framework <name>'
    property var rpaths

    FileTagger {
        pattern: "*.c"
        fileTags: ["c"]
    }

    FileTagger {
        pattern: "*.C"
        fileTags: ["c"]
    }

    FileTagger {
        pattern: "*.cpp"
        fileTags: ["cpp"]
    }

    FileTagger {
        pattern: "*.cxx"
        fileTags: ["cpp"]
    }

    FileTagger {
        pattern: "*.c++"
        fileTags: ["cpp"]
    }

    FileTagger {
        pattern: "*.h"
        fileTags: ["hpp"]
    }

    FileTagger {
        pattern: "*.H"
        fileTags: ["hpp"]
    }

    FileTagger {
        pattern: "*.hpp"
        fileTags: ["hpp"]
    }

    FileTagger {
        pattern: "*.hxx"
        fileTags: ["hpp"]
    }

    FileTagger {
        pattern: "*.h++"
        fileTags: ["hpp"]
    }
}
