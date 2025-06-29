{{- define "webapp.labels" -}}
app.kubernetes.io/name: {{ include "webapp-chart-name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "webapp-chart-name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- define "webapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{ .Values.serviceAccount.name }}
{{- else -}}
{{ include "webapp-chart-name" . }}-sa
{{- end -}}
{{- end -}}