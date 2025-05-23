package trino
# Taken from https://github.com/stackabletech/trino-operator/blob/main/tests/templates/kuttl/opa-authorization/trino_rules/actual_permissions.rego
# License: Open Software License version 3.0

# This file contains the requested_permissions rule which returns a set
# of required permissions for the given operation including the
# requested resource. Operations with the same set of required
# permissions are grouped together.
# The defined permissions should be identical to the ones implemented
# for the file-based access control
# (https://trino.io/docs/current/security/file-system-access-control.html).

action := input.action

operation := action.operation

requested_permissions := permissions if {
	operation == "AccessCatalog"
	permissions := {{
		"resource": "catalog",
		"catalogName": action.resource.catalog.name,
		"allow": "read-only",
	}}
}

requested_permissions := permissions if {
	operation in {
		"CreateSchema",
		"DropSchema",
		"ShowCreateSchema",
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.schema.catalogName,
			"allow": "all",
		},
		{
			"resource": "schema",
			"catalogName": action.resource.schema.catalogName,
			"schemaName": action.resource.schema.schemaName,
			"owner": true,
		},
	}
}

requested_permissions := permissions if {
	operation in {
		"AddColumn",
		"AlterColumn",
		"CreateMaterializedView",
		"CreateTable",
		"CreateView",
		"CreateViewWithSelectFromColumns",
		"DropColumn",
		"DropMaterializedView",
		"DropTable",
		"DropView",
		"RenameColumn",
		"SetColumnComment",
		"SetMaterializedViewProperties",
		"SetTableComment",
		"SetTableProperties",
		"SetViewComment",
		"ShowCreateTable",
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.table.catalogName,
			"allow": "all",
		},
		{
			"resource": "table",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"privileges": {"allOf": {"OWNERSHIP"}},
		},
	}
}

requested_permissions := permissions if {
	operation in {
		"RefreshMaterializedView",
		"UpdateTableColumns",
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.table.catalogName,
			"allow": "all",
		},
		{
			"resource": "table",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"privileges": {"allOf": {"UPDATE"}},
		},
	}
}

requested_permissions := permissions if {
	operation in {
		"DeleteFromTable",
		"TruncateTable",
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.table.catalogName,
			"allow": "all",
		},
		{
			"resource": "table",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"privileges": {"allOf": {"DELETE"}},
		},
	}
}

requested_permissions := permissions if {
	operation == "ExecuteQuery"
	permissions := {{
		"resource": "query",
		"allow": {"execute"},
	}}
}

requested_permissions := permissions if {
	operation == "ExecuteTableProcedure"

	# Executing table procedures is always allowed
	permissions := set()
}

requested_permissions := permissions if {
	operation == "FilterColumns"
	permissions := {
		{
			"resource": "table",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"privileges": {"anyOf": {
				"SELECT",
				"INSERT",
				"DELETE",
				"UPDATE",
				"OWNERSHIP",
				"GRANT_SELECT",
			}},
		},
		{
			"resource": "column",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"columnName": action.resource.table.columnName,
			"allow": true,
		},
	}
}

requested_permissions := permissions if {
	operation == "KillQueryOwnedBy"
	permissions := {{
		"resource": "query_owned_by",
		"user": action.resource.user.user,
		"groups": action.resource.user.groups,
		"allow": {"kill"},
	}}
}

requested_permissions := permissions if {
	operation in {
		"FilterViewQueryOwnedBy",
		"ViewQueryOwnedBy",
	}
	permissions := {{
		"resource": "query_owned_by",
		"user": action.resource.user.user,
		"groups": action.resource.user.groups,
		"allow": {"view"},
	}}
}

requested_permissions := permissions if {
	operation == "FilterTables"
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.table.catalogName,
			"allow": "read-only",
		},
		{
			"resource": "table",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"privileges": {"anyOf": {
				"SELECT",
				"INSERT",
				"DELETE",
				"UPDATE",
				"OWNERSHIP",
				"GRANT_SELECT",
			}},
		},
	}
}

requested_permissions := permissions if {
	operation in {
		"CreateFunction",
		"DropFunction",
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.function.catalogName,
			"allow": "all",
		},
		{
			"resource": "function",
			"catalogName": action.resource.function.catalogName,
			"schemaName": action.resource.function.schemaName,
			"functionName": action.resource.function.functionName,
			"privileges": {"OWNERSHIP"},
		},
	}
}

requested_permissions := permissions if {
	operation in {
		"ExecuteFunction",
		"FilterFunctions",
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.function.catalogName,
			"allow": "read-only",
		},
		{
			"resource": "function",
			"catalogName": action.resource.function.catalogName,
			"schemaName": action.resource.function.schemaName,
			"functionName": action.resource.function.functionName,
			"privileges": {"EXECUTE"},
		},
	}
}

requested_permissions := permissions if {
	operation == "ExecuteProcedure"
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.function.catalogName,
			"allow": "read-only",
		},
		{
			"resource": "procedure",
			"catalogName": action.resource.function.catalogName,
			"schemaName": action.resource.function.schemaName,
			"functionName": action.resource.function.functionName,
			"privileges": {"EXECUTE"},
		},
	}
}

requested_permissions := permissions if {
	operation == "CreateViewWithExecuteFunction"
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.function.catalogName,
			"allow": "read-only",
		},
		{
			"resource": "function",
			"catalogName": action.resource.function.catalogName,
			"schemaName": action.resource.function.schemaName,
			"functionName": action.resource.function.functionName,
			"privileges": {"GRANT_EXECUTE"},
		},
	}
}

requested_permissions := permissions if {
	operation == "ImpersonateUser"
	permissions := {{
		"resource": "impersonation",
		"user": action.resource.user.user,
		"allow": true,
	}}
}

requested_permissions := permissions if {
	operation == "InsertIntoTable"
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.table.catalogName,
			"allow": "all",
		},
		{
			"resource": "table",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"privileges": {"allOf": {"INSERT"}},
		},
	}
}

requested_permissions := permissions if {
	operation == "ReadSystemInformation"
	permissions := {{
		"resource": "system_information",
		"allow": {"read"},
	}}
}

requested_permissions := permissions if {
	operation == "RenameSchema"
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.schema.catalogName,
			"allow": "all",
		},
		{
			"resource": "catalog",
			"catalogName": action.targetResource.schema.catalogName,
			"allow": "all",
		},
		{
			"resource": "schema",
			"catalogName": action.resource.schema.catalogName,
			"schemaName": action.resource.schema.schemaName,
			"owner": true,
		},
		{
			"resource": "schema",
			"catalogName": action.targetResource.schema.catalogName,
			"schemaName": action.targetResource.schema.schemaName,
			"owner": true,
		},
	}
}

requested_permissions := permissions if {
	operation in {
		"RenameMaterializedView",
		"RenameTable",
		"RenameView",
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.table.catalogName,
			"allow": "all",
		},
		{
			"resource": "catalog",
			"catalogName": action.targetResource.table.catalogName,
			"allow": "all",
		},
		{
			"resource": "table",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"privileges": {"allOf": {"OWNERSHIP"}},
		},
		{
			"resource": "table",
			"catalogName": action.targetResource.table.catalogName,
			"schemaName": action.targetResource.table.schemaName,
			"tableName": action.targetResource.table.tableName,
			"privileges": {"allOf": {"OWNERSHIP"}},
		},
	}
}

requested_permissions := permissions if {
	operation == "SelectFromColumns"
	column_permissions := {
	{
		"resource": "column",
		"catalogName": action.resource.table.catalogName,
		"schemaName": action.resource.table.schemaName,
		"tableName": action.resource.table.tableName,
		"columnName": column_name,
		"allow": true,
	} |
		some column_name in action.resource.table.columns
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.table.catalogName,
			"allow": "read-only",
		},
		{
			"resource": "table",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"privileges": {"allOf": {"SELECT"}},
		},
	} | column_permissions
}

requested_permissions := permissions if {
	operation == "SetSchemaAuthorization"
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.schema.catalogName,
			"allow": "all",
		},
		{
			"resource": "schema",
			"catalogName": action.resource.schema.catalogName,
			"schemaName": action.resource.schema.schemaName,
			"owner": true,
		},
		{
			"resource": "authorization",
			"granteeName": action.grantee.name,
			"granteeType": action.grantee.type,
			"allow": true,
		},
	}
}

requested_permissions := permissions if {
	operation in {
		"SetTableAuthorization",
		"SetViewAuthorization",
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.table.catalogName,
			"allow": "all",
		},
		{
			"resource": "table",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"privileges": {"allOf": {"OWNERSHIP"}},
		},
		{
			"resource": "authorization",
			"granteeName": action.grantee.name,
			"granteeType": action.grantee.type,
			"allow": true,
		},
	}
}

requested_permissions := permissions if {
	operation == "ShowColumns"
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.table.catalogName,
			"allow": "read-only",
		},
		{
			"resource": "table",
			"catalogName": action.resource.table.catalogName,
			"schemaName": action.resource.table.schemaName,
			"tableName": action.resource.table.tableName,
			"privileges": {"anyOf": {
				"SELECT",
				"INSERT",
				"DELETE",
				"UPDATE",
				"OWNERSHIP",
				"GRANT_SELECT",
			}},
		},
	}
}

requested_permissions := permissions if {
	operation in {
		"FilterCatalogs",
		"ShowSchemas",
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.catalog.name,
			"allow": "read-only",
		},
		{
			"resource": "catalog_visibility",
			"catalogName": action.resource.catalog.name,
		},
	}
}

requested_permissions := permissions if {
	operation in {
		"FilterSchemas",
		"ShowFunctions",
		"ShowTables",
	}
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.schema.catalogName,
			"allow": "read-only",
		},
		{
			"resource": "schema_visibility",
			"catalogName": action.resource.schema.catalogName,
			"schemaName": action.resource.schema.schemaName,
		},
	}
}

requested_permissions := permissions if {
	operation == "SetCatalogSessionProperty"
	permissions := {
		{
			"resource": "catalog",
			"catalogName": action.resource.catalogSessionProperty.catalogName,
			"allow": "read-only",
		},
		{
			"resource": "catalog_session_properties",
			"catalogName": action.resource.catalogSessionProperty.catalogName,
			"propertyName": action.resource.catalogSessionProperty.propertyName,
			"allow": true,
		},
	}
}

requested_permissions := permissions if {
	operation == "SetSystemSessionProperty"
	permissions := {{
		"resource": "system_session_properties",
		"propertyName": action.resource.systemSessionProperty.name,
		"allow": true,
	}}
}

requested_permissions := permissions if {
	operation == "WriteSystemInformation"
	permissions := {{
		"resource": "system_information",
		"allow": {"write"},
	}}
}

requested_authorization_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "authorization"
}

requested_catalog_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "catalog"
}

requested_catalog_session_properties_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "catalog_session_properties"
}

requested_catalog_visibility_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "catalog_visibility"
}

requested_column_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "column"
}

requested_function_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "function"
}

requested_impersonation_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "impersonation"
}

requested_procedure_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "procedure"
}

requested_query_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "query"
}

requested_query_owned_by_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "query_owned_by"
}

requested_schema_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "schema"
}

requested_schema_visibility_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "schema_visibility"
}

requested_table_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "table"
}

requested_system_information_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "system_information"
}

requested_system_session_properties_permissions contains permission if {
	some permission in requested_permissions
	permission.resource == "system_session_properties"
}

requested_column_mask := request if {
	operation == "GetColumnMask"
	request := {
		"catalogName": action.resource.column.catalogName,
		"schemaName": action.resource.column.schemaName,
		"tableName": action.resource.column.tableName,
		"columnName": action.resource.column.columnName,
	}
}

requested_row_filters := request if {
	operation == "GetRowFilters"
	request := {
		"catalogName": action.resource.table.catalogName,
		"schemaName": action.resource.table.schemaName,
		"tableName": action.resource.table.tableName,
	}
}
