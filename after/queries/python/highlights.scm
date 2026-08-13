;; extends

; Spell check identifiers we declare ourselves. Names we only use (imports,
; library calls) are left alone: they are somebody else's spelling.
(function_definition name: (identifier) @spell)
(class_definition name: (identifier) @spell)
(parameters (identifier) @spell)
(typed_parameter (identifier) @spell)
(default_parameter name: (identifier) @spell)
(assignment left: (identifier) @spell)
(assignment left: (pattern_list (identifier) @spell))
