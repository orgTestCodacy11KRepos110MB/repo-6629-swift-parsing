
import Parsing

var input = """
1,Blob,true
2,Blob Jr,false
3,Blob Sr,true
4,"Blob, Esq.",true
"""[...]

struct User {
  var id: Int
  var name: String
  var admin: Bool
}

let field = OneOf {
  Parse {
    "\""
    Prefix { $0 != "\"" }.map(String.init)
    "\""
  }

  Prefix { $0 != "," }.map(String.init)
}

let zeroOrOneSpace = OneOf {
  " "
  ""
}

let user = Parse(User.init(id:name:admin:)) {
  Int.parser()
  Skip {
    ","
    zeroOrOneSpace
  }
  field
  Skip {
    ","
    zeroOrOneSpace
  }
  Bool.parser()
}

let users = Many {
  user
} separator: {
  "\n"
} terminator: {
  End()
}

let parsedUsers = try users.parse(&input)
input
1



func print(user: User) -> String {
  "\(user.id), "
  + (user.name.contains(",") ? "\"\(user.name)\"" : user.name)
  + ", \(user.admin)"
}
func print(users: [User]) -> String {
  users.map(print(user:)).joined(separator: "\n")
}

print(print(users: parsedUsers))


protocol Printer {
  associatedtype Input
  associatedtype Output
  func print(_ output: Output, to input: inout Input) throws
}

struct UserPrinter: Printer {
  func print(_ user: User, to input: inout String) {
    input.append(contentsOf: "\(user.id), ")
    if user.name.contains(",") {
      input.append(contentsOf: "\"\(user.name)\"")
    } else {
      input.append(contentsOf: user.name)
    }
    input.append(contentsOf: ", \(user.admin)")
  }
}


struct UsersPrinter: Printer {
  func print(_ output: [User], to input: inout String) {
    for user in output {
      UserPrinter().print(user, to: &input)
      input += "\n"
    }
    input.removeLast()
  }
}

var inputString = ""
UsersPrinter().print(
  [
    .init(id: 1, name: "Blob", admin: true),
    .init(id: 2, name: "Blob jr", admin: false),
    .init(id: 3, name: "Blob, Esq.", admin: true),
  ],
  to: &inputString
)
inputString

extension String: Printer {
  func print(_ output: (), to input: inout Substring) {
    input.append(contentsOf: self)
  }
}

input = "Hello World"
try "Hello".parse(&input)
"Hello".print((), to: &input)
input


input = ""
"Hello".print((), to: &input)
try "Hello".parse(&input)
input

//"Hello".print("Hello".parse("Hello")!) == "Hello" // true

struct PrintingError: Error {}

extension Prefix: Printer where Input == Substring {
  func print(_ output: Input, to input: inout Input) throws {
    guard output.allSatisfy(self.predicate!)
    else { throw PrintingError() }

    input.append(contentsOf: output)
  }
}

try Prefix
{ $0 != "," }.parse("Hello")

//input = ""
//try Prefix
//{ $0 != "," }.print("Hello,", to: &input) // error was thrown: PrintingError()
//input

input = ""
try Prefix
{ $0 != "\"" }.print("Blob, Esq.", to: &input) // error was thrown: PrintingError()
input

/*
 error: unexpected output

 output:
 "Hello,"
       ^ element satisfying predicate
 */

1
2

extension Parse: Printer where Parsers: Printer {
  func print(_ output: Parsers.Output, to input: inout Parsers.Input) throws {
    try self.parsers.print(output, to: &input)
  }
}


input = ""
try Parse {
  Prefix { $0 != "\"" }
}
.print("Blob, Esq.", to: &input)
input


extension Parsers.ZipVOV: Printer
where
  P0: Printer,
  P1: Printer,
  P2: Printer
{
  func print(_ output: (P1.Output), to input: inout P0.Input) throws {
    try self.p0.print((), to: &input)
    try self.p1.print(output, to: &input)
    try self.p2.print((), to: &input)
  }
}

//extension Parsers.Map: Printer where Upstream: Printer {
//  func print(_ output: Output, to input: inout Upstream.Input) throws {
//    self.upstream.print(<#T##output: Upstream.Output##Upstream.Output#>, to: &<#T##Upstream.Input#>)
//  }
//}


let quotedField = Parse {
  "\""
  Prefix { $0 != "\"" }
  "\""
}

input = ""
try quotedField.print("Blob, Esq.", to: &input)
input // ""Blob, Esq.""

try quotedField.parse(&input)
input // ""

try quotedField.print("Blob, Esq.", to: &input)
input // ""Blob, Esq.""

extension OneOf: Printer where Parsers: Printer {
  func print(_ output: Parsers.Output, to input: inout Parsers.Input) throws {
    try self.parsers.print(output, to: &input)
  }
}

extension Parsers.OneOf2: Printer where P0: Printer, P1: Printer {
  func print(_ output: P0.Output, to input: inout P0.Input) throws {
    do {
      try self.p1.print(output, to: &input)
    } catch {
      try self.p0.print(output, to: &input)
    }
  }
}


let _field = OneOf {
  Parse {
    "\""
    Prefix { $0 != "\"" }
    "\""
  }

  Prefix { $0 != "," }
}

try field.parse("\"Blob, Esq.\",true") // "\"Blob,"


input = ""
try _field.print("Blob, Esq.", to: &input)
input // ""Blob, Esq.""

input = ""
try _field.print("Blob Jr.", to: &input)
input // ""Blob Jr.""


extension Skip: Printer where Parsers: Printer, Parsers.Output == Void {
  func print(_ output: (), to input: inout Parsers.Input) throws {
    try self.parsers.print((), to: &input)
  }
}

extension Parsers.ZipVV: Printer where P0: Printer, P1: Printer {
  func print(_ output: (), to input: inout P0.Input) throws {
    try self.p0.print((), to: &input)
    try self.p1.print((), to: &input)
  }
}



extension Parsers.IntParser: Printer where Input == Substring.UTF8View {
  func print(_ output: Output, to input: inout Substring.UTF8View) throws {
    input.append
  }
}
