@tool
extends CodeEdit

@export var keyword_color: Color

@export_tool_button("update") var _update_color = update_color

func update_color():
	self.syntax_highlighter.keyword_colors["function"] = keyword_color
	self.syntax_highlighter.keyword_colors["end"] = keyword_color
	self.syntax_highlighter.keyword_colors["for"] = keyword_color
	self.syntax_highlighter.keyword_colors["while"] = keyword_color
	self.syntax_highlighter.keyword_colors["do"] = keyword_color
	self.syntax_highlighter.keyword_colors["if"] = keyword_color
	self.syntax_highlighter.keyword_colors["then"] = keyword_color
	self.syntax_highlighter.keyword_colors["return"] = keyword_color
	self.syntax_highlighter.keyword_colors["continue"] = keyword_color
	self.syntax_highlighter.keyword_colors["break"] = keyword_color
	self.syntax_highlighter.clear_highlighting_cache()
	self.syntax_highlighter.update_cache()
	self.syntax_highlighter.emit_changed()
	
