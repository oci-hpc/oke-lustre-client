{{/*
Expand the name of the chart.
*/}}
{{- define "lustre-client-installer.name" -}}
{{- default .Chart.Name .Values.daemonset.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lustre-client-installer.fullname" -}}
{{- if .Values.daemonset.name }}
{{- printf "%s" .Values.daemonset.name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end -}}

{{/*
Create chart-specific labels
*/}}
{{- define "lustre-client-installer.labels" -}}
helm.sh/chart: {{ include "lustre-client-installer.chart" . }}
{{ include "lustre-client-installer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "lustre-client-installer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lustre-client-installer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
job: {{ include "lustre-client-installer.fullname" . }}
{{- end -}}

{{/*
Determine the serviceAccountName
*/}}
{{- define "lustre-client-installer.serviceAccountName" -}}
{{- if .Values.rbac.create }}
{{- include "lustre-client-installer.name" . }}-sa
{{- else }}
{{- .Values.daemonset.serviceAccountName }}
{{- end }}
{{- end -}}

{{/*
Chart API Version
*/}}
{{- define "lustre-client-installer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}