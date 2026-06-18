# Argo CD Applications

This folder holds Argo CD `Application` manifests. The root app (defined in `gitops/bootstrap/root-app.yaml`) auto-discovers all manifests in this directory via `directory.recurse: true`.

**To add a new application:** drop a new `Application` manifest YAML file into this folder. Argo CD will automatically detect and sync it.