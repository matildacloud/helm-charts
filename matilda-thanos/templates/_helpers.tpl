{{- /*
Helper templates for Thanos Helm chart
*/ -}}

{{- define "thanos.query.fullname" -}}
{{- printf "%s-%s" .Release.Name "thanos-query" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "thanos.query.labels" -}}
app.kubernetes.io/name: {{ include "thanos.query.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/component: query
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}

{{- define "thanos.query.name" -}}
thanos-query
{{- end -}}


{{- define "thanos.store.fullname" -}}
{{- printf "%s-%s" .Release.Name "thanos-store" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "thanos.store.labels" -}}
app.kubernetes.io/name: {{ include "thanos.store.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/component: store
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}

{{- define "thanos.store.name" -}}
thanos-store
{{- end -}}


{{- define "thanos.receive.fullname" -}}
{{- printf "%s-%s" .Release.Name "thanos-receive" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "thanos.receive.labels" -}}
app.kubernetes.io/name: {{ include "thanos.receive.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/component: receive
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}

{{- define "thanos.receive.name" -}}
thanos-receive
{{- end -}}

{{- define "thanos.common.labels" -}}
app.kubernetes.io/name: {{ include "thanos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}

{{- define "thanos.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "thanos.objstore.secretName" -}}
{{- .Values.objstore.existingSecret -}}
{{- end -}}

