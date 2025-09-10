{{/*
Validate required values for Thanos deployment
*/}}

{{- define "thanos.validations.objstore" -}}
{{- if not .Values.objstore.existingSecret -}}
{{- fail "objstore.existingSecret is required - S3 secret must be created externally" -}}
{{- end -}}
{{- end -}}

{{- define "thanos.validations.namespace" -}}
{{- if not .Values.namespace.name -}}
{{- fail "namespace.name is required" -}}
{{- end -}}
{{- end -}}

{{- define "thanos.validations.image" -}}
{{- if not .Values.image.repository -}}
{{- fail "image.repository is required" -}}
{{- end -}}
{{- if not .Values.image.tag -}}
{{- fail "image.tag is required" -}}
{{- end -}}
{{- end -}}

{{- define "thanos.validations.resources" -}}
{{- if .Values.query.resources -}}
{{- if .Values.query.resources.requests -}}
{{- if not .Values.query.resources.requests.cpu -}}
{{- fail "query.resources.requests.cpu is required when query.resources.requests is specified" -}}
{{- end -}}
{{- if not .Values.query.resources.requests.memory -}}
{{- fail "query.resources.requests.memory is required when query.resources.requests is specified" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
