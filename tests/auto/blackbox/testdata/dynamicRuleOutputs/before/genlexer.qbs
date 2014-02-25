/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Build Suite.
**
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
****************************************************************************/

import qbs 1.0
import qbs.File
import qbs.FileInfo
import qbs.TextFile
import "flexoptionsreader.js" as FlexOptionsReader

Project {
    Product {
        name: "genlexer"
        type: "application"
        Depends { name: "cpp" }
        Group {
            files: ["numbers.l"]
            fileTags: ["flex"]
        }
        property bool isFlexAvailable: File.exists("/usr/bin/flex") // ### replace with PathProbe
        Rule {
            inputs: ["flex"]
            outputFileTags: ["c", "hpp"]
            outputArtifacts: {
                var options = FlexOptionsReader.readFlexOptions(input.filePath);
                var sourceFileName = options["outfile"] || "lex.yy.c";
                var headerFileName = options["header-file"];
                var result = [{
                    filePath: "GeneratedFiles/" + product.name + "/" + sourceFileName,
                    fileTags: ["c"]
                }];
                if (headerFileName) {
                    result.push({
                            filePath: "GeneratedFiles/" + product.name + "/" + headerFileName,
                            fileTags: ["hpp"]
                        });
                }
                return result;
            }
            prepare: {
                var cmd;
                if (product.isFlexAvailable) {
                    // flex is available. Let's call it.
                    cmd = new Command("flex", [input.filePath]);
                    cmd.workingDirectory = product.buildDirectory + "/GeneratedFiles/" + product.name;
                } else {
                    // No flex available here, generate some C source and header.
                    cmd = new JavaScriptCommand();
                    cmd.sourceFileName = outputs["c"][0].filePath;
                    cmd.headerFileName = outputs["hpp"] ? outputs["hpp"][0].filePath : "";
                    cmd.sourceCode = function() {
                        var fsrc = new TextFile(sourceFileName, TextFile.WriteOnly);
                        if (headerFileName) {
                            fsrc.write("#include \"" + FileInfo.fileName(headerFileName)
                                    + "\"\n\n");
                            var fhdr = new TextFile(headerFileName, TextFile.WriteOnly);
                            fhdr.write("// a rather empty header file\n");
                            fhdr.close();
                        }
                        fsrc.write("int main() { return 0; }\n");
                        fsrc.close();
                    };
                }
                cmd.description = "flexing " + FileInfo.fileName(input.filePath);
                return cmd;
            }
        }
    }
}

