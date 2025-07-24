{{/*
Expand the name of the chart.
*/}}
{{- define "matilda-k8s-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "matilda-k8s-agent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "matilda-k8s-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "matilda-k8s-agent.labels" -}}
helm.sh/chart: {{ include "matilda-k8s-agent.chart" . }}
{{ include "matilda-k8s-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "matilda-k8s-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "matilda-k8s-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "matilda-k8s-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "matilda-k8s-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the configmap to use
*/}}
{{- define "matilda-k8s-agent.configMapName" -}}
{{- printf "%s-config" (include "matilda-k8s-agent.fullname" .) }}
{{- end }}

{{/*
Create the name of the secret to use
*/}}
{{- define "matilda-k8s-agent.secretName" -}}
{{- printf "%s-secret" (include "matilda-k8s-agent.fullname" .) }}
{{- end }}

{{/*
RabbitMQ connection string
*/}}
{{- define "matilda-k8s-agent.rabbitmqUrl" -}}
{{- printf "amqp://%s:%s@%s:%s" .Values.rabbitMQ.user .Values.rabbitMQ.password .Values.rabbitMQ.host .Values.rabbitMQ.port }}
{{- end }}

{{/*
Security context for containers
*/}}
{{- define "matilda-k8s-agent.securityContext" -}}
{{- if .Values.securityContext.enabled }}
runAsNonRoot: {{ .Values.securityContext.runAsNonRoot }}
runAsUser: {{ .Values.securityContext.runAsUser }}
runAsGroup: {{ .Values.securityContext.runAsGroup }}
fsGroup: {{ .Values.securityContext.fsGroup }}
{{- if .Values.securityContext.capabilities }}
capabilities:
  {{- toYaml .Values.securityContext.capabilities | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Container security context
*/}}
{{- define "matilda-k8s-agent.containerSecurityContext" -}}
{{- if .Values.containerSecurityContext.enabled }}
runAsNonRoot: {{ .Values.containerSecurityContext.runAsNonRoot }}
runAsUser: {{ .Values.containerSecurityContext.runAsUser }}
runAsGroup: {{ .Values.containerSecurityContext.runAsGroup }}
readOnlyRootFilesystem: {{ .Values.containerSecurityContext.readOnlyRootFilesystem }}
allowPrivilegeEscalation: {{ .Values.containerSecurityContext.allowPrivilegeEscalation }}
{{- if .Values.containerSecurityContext.capabilities }}
capabilities:
  {{- toYaml .Values.containerSecurityContext.capabilities | nindent 2 }}
{{- end }}
{{- end }}
{{- end }} 