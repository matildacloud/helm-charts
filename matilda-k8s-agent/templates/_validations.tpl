{{/*
Validate required values
*/}}
{{- define "matilda-k8s-agent.validateValues" -}}
{{- $errors := list -}}

{{- if not .Values.assetid -}}
{{- $errors = append $errors "assetid is required. Please provide it using --set assetid=YOUR_ASSET_ID" -}}
{{- end -}}

{{- if not .Values.integrationid -}}
{{- $errors = append $errors "integrationid is required. Please provide it using --set integrationid=YOUR_INTEGRATION_ID" -}}
{{- end -}}

{{- if $errors -}}
{{- printf "\n" -}}
{{- range $errors -}}
{{- printf "ERROR: %s\n" . -}}
{{- end -}}
{{- printf "\n" -}}
{{- fail "Required values are missing" -}}
{{- end -}}
{{- end -}} 