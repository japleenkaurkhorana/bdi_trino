# METADATA
# description: Utility package which extends the built-in functions
package util
# Taken from https://github.com/stackabletech/trino-operator/blob/main/tests/templates/kuttl/opa-authorization/trino_rules/actual_permissions.rego
# License: Open Software License version 3.0

# METADATA
# description: |
#   Matches the entire string against a regular expression.
#
#   pattern (string)  regular expression
#   value (string)    value to match against pattern
#
#   Returns:
#     result (boolean)
match_entire(pattern, value) if {
	# Add the anchors ^ and $
	pattern_with_anchors := concat("", ["^", pattern, "$"])

	regex.match(pattern_with_anchors, value)
}
