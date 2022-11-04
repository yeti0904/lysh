import std.stdio;
import std.process;
import lexer;
import commandManager;

void Interpret(Lexer_Token[] tokens) {
	for (size_t i = 0; i < tokens.length; ++i) {
		auto token = tokens[i];
		
		switch (token.type) {
			case Lexer_TokenType.End: break;
			case Lexer_TokenType.Command: {
				string[] args       = [token.contents];
				CommandManager cmds = CommandManagerInstance();
				
				++ i;
				while (tokens[i].type != Lexer_TokenType.End) {
					if (tokens[i].type != Lexer_TokenType.Parameter) {
						writefln(
							"Unexpected token %s: %s",
							Lexer_TokenTypeToString(tokens[i].type),
							tokens[i].contents
						);
						return;
					}
					args ~= [tokens[i].contents];
					++ i;
				}

				Command* cmd = cmds.GetCommand(args[0]);
				if (cmd) {
					cmd.func(args);
				}
				else {
					Pid child;
					try {
						child = spawnProcess(args);
					}
					catch (ProcessException e) {
						writefln("ProcessException: %s", e.msg);
						return;
					}

					try {
						wait(child);
					}
					catch (ProcessException e) {
						writefln("ProcessException: %s", e.msg);
						return;
					}
				}
				break;
			}
			default: {
				writefln(
					"Unexpected token %s: %s",
					Lexer_TokenTypeToString(tokens[i].type), tokens[i].contents
				);
				return;
			}
		}
	}
}
