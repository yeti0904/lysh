import std.stdio;
import std.string;
import std.process;
import readlineFunctions;
import lexer;
import interpreter;
import commandManager;
import commands;

const string usage = `
Usage: ysh [-dt/--dump-tokens]

-dt/--dump-tokens:
    Prints out all tokens after a command is typed in
`;

void main(string[] args) {
	bool   run           = true;
	bool   dumpTokens    = false;
	string defaultPrompt = environment.get("USER", "") == "root"? "# " : "$ ";
	
	for (size_t i = 1; i < args.length; ++i) {
		if (args[i][0] == '-') {
			switch (args[i]) {
				case "-h":
				case "--help": {
					writeln(usage);
					run = false;
					break;
				}
				case "-dt":
				case "--dump-tokens": {
					dumpTokens = true;
					break;
				}
				default: {
					writefln("Unrecognised parameter: %s", args[i]);
					break;
				}
			}
		}
	}

	CommandManager cmds = CommandManagerInstance();
	cmds.RegisterCommand(
		"help", &Commands_Help,
		[
			"help <command>",
			"when command is not given, show the names of all registered commands",
			"when command is given, show information for that command"
		]
	);
	cmds.RegisterCommand(
		"exit", &Commands_Exit,
		[
			"exit <status>",
			"when status is not given, exit with status 0",
			"when status is given, exit with that status"
		]
	);

	while (run) {
		string prompt = environment.get("YSH_PROMPT");
		if (prompt is null) {
			prompt = defaultPrompt;
		}
	
		string input  = Readline(prompt);
		auto   tokens = Lexer_Lex(input);
		if (dumpTokens) {
			Lexer_DumpTokens(tokens);
		}
		Interpret(tokens);
	}
}
