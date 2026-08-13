;; extends

(function_declaration name: (identifier) @spell)
(function_declaration name: (dot_index_expression field: (identifier) @spell))
(function_declaration name: (method_index_expression method: (identifier) @spell))
(parameters (identifier) @spell)
(assignment_statement (variable_list name: (identifier) @spell))
(field name: (identifier) @spell)
