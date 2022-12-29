// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1

package v1beta1

// TaskResult used to describe the results of a task
#TaskResult: {
	// Name the given name
	name: string @go(Name)

	// Type is the user-specified type of the result. The possible type
	// is currently "string" and will support "array" in following work.
	// +optional
	type?: #ResultsType @go(Type)

	// Properties is the JSON Schema properties to support key-value pairs results.
	// +optional
	properties?: {[string]: #PropertySpec} @go(Properties,map[string]PropertySpec)

	// Description is a human-readable description of the result
	// +optional
	description?: string @go(Description)
}

// TaskRunResult used to describe the results of a task
#TaskRunResult: {
	// Name the given name
	name: string @go(Name)

	// Type is the user-specified type of the result. The possible type
	// is currently "string" and will support "array" in following work.
	// +optional
	type?: #ResultsType @go(Type)

	// Value the given value of the result
	value: #ParamValue @go(Value)
}

// ResultValue is a type alias of ParamValue
#ResultValue: _

// ResultsType indicates the type of a result;
// Used to distinguish between a single string and an array of strings.
// Note that there is ResultType used to find out whether a
// PipelineResourceResult is from a task result or not, which is different from
// this ResultsType.
#ResultsType: string // #enumResultsType

#enumResultsType:
	#ResultsTypeString |
	#ResultsTypeArray |
	#ResultsTypeObject

#ResultsTypeString: #ResultsType & "string"
#ResultsTypeArray:  #ResultsType & "array"
#ResultsTypeObject: #ResultsType & "object"
