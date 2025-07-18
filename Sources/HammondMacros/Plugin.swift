import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MyMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RequestMacro.self,
        MarkerMacro.self,
        EncodableRequestMacro.self,
        NewtypeMacro.self,
    ]
}
