{{/*
Expand the name of the chart.
*/}}
{{- define "observability-carbon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "observability-carbon.fullname" -}}
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
Chart label.
*/}}
{{- define "observability-carbon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "observability-carbon.labels" -}}
helm.sh/chart: {{ include "observability-carbon.chart" . }}
{{ include "observability-carbon.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
carbon.region: {{ .Values.carbon.region | quote }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "observability-carbon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "observability-carbon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
