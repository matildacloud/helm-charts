{{/*
Validate required values
*/}}
{{- define "matilda-k8s-agent.validateValues" -}}
{{- $errors := list -}}
{{- $warnings := list -}}

{{- if not .Values.api_host -}}
{{- $errors = append $errors "api_host is required" -}}
{{- end -}}

{{- if not .Values.api_key -}}
{{- $errors = append $errors "api_key is required" -}}
{{- end -}}

{{- if not .Values.id -}}
{{- $errors = append $errors "id is required" -}}
{{- end -}}


{{- if $errors -}}
{{- printf "ERROR: %s" (join ", " $errors) | fail -}}
{{- end -}}

{{- if $warnings -}}
{{- printf "WARNING: %s" (join ", " $warnings) -}}
{{- end -}}
{{- end -}}
