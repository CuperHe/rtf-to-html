tree grammar Convert;

options {
	tokenVocab = Rtf;
	ASTLabelType=CommonTree;
}

@members {
	Engine engine;

	public Convert(TreeNodeStream input, Engine engine) {
		this(input);
		this.engine = engine;
	}
}

rtf: { engine.start(); } ^(RTF NUMBER header body) { engine.end(); } ;

entity: . | ^(. entity*) ;

hword: DEFF NUMBER | ANSI | ANSICPG NUMBER { engine.ansicpg(Integer.parseInt($NUMBER.text)); } | DEFLANG NUMBER | DEFLANGFE NUMBER | DEFTAB NUMBER | UC NUMBER ;
hentity: hword | ^((COLORTBL | STYLESHEET | INFO | GENERATOR) entity*) | fonttbl ;

fonttbl: ^(FONTTBL fontdesc*) ;
fontdesc: ^(F NUMBER TEXT) { engine.font($NUMBER.text, new Engine.Font($TEXT.text.substring(0, $TEXT.text.length() - 1))); } ;

header: hentity* ;

bstart: 
	TEXT { engine.text($TEXT.text); } | 
	LINE { engine.line(); } | 
	NBSP { engine.outText("\u00a0"); } | 
	HEXCHAR { engine.outText("#"); } |
	BULLET { engine.outText("\u2022"); } |
	SLASH { engine.outText("\\"); } | 
	OPENBRACE { engine.outText("{"); } | 
	CLOSEBRACE { engine.outText("}"); } |
	PAR { engine.par(); } | 
	PARD | 
	FS NUMBER { engine.fs(Integer.parseInt($NUMBER.text)); } | 
	F NUMBER |
	I NUMBER { engine.i(false); } | 
	I { engine.i(true); } |
	B { engine.b(true); } |
	PLAIN { engine.plain(); } |
	EMDASH { engine.emdash(); } | 
	ENDASH { engine.endash(); } | 
	B NUMBER { engine.b(false); } | 
	RQUOTE { engine.rquote(); } |
	LANG NUMBER | 
	^(TREE { engine.push(); } bentity* { engine.pop(); } ) ;
bentity: bstart ;
body: { engine.body(); } bstart bentity* { engine.endbody(); } ;
