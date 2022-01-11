# buildpacks

## How to run this demo

Execute the following commands from the root of this repository:

```bash
# Only if a cluster is needed.
make setup-minikube

# Setup tekton w/ chains
make setup-tekton-chains tekton-generate-keys

#### Begin local minikube registry
##
## Use this section if you want to use the minikube registry for
## publishing OCI artifacts.
##
## In a separate terminal, port forward the registry: defaults to <host-ip>:8888
#  make registry-proxy
##
## Set the registry for use in buildpacks.sh
#  export REGISTRY=<host-ip>:8888
##
#### End local minikube registry

# Run a new pipeline.
make example-buildpacks
# Or re-run the last one.
# tkn pipeline start buildpacks -L

# Export the value of APP_IMAGE from the pipelinerun describe as DOCKER_IMG:
export DOCKER_IMG=$(tkn pr describe --last -o jsonpath='{.spec.params[?(@.name=="APP_IMAGE")].value}')

# Wait until it completes.
tkn pr logs --last -f

# Ensure it has been signed.
tkn tr describe --last -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}'
# Should output "true"

# Double check that the attestation and the signature were uploaded to the OCI.
crane ls "${DOCKER_IMG}"

# Verify the image and the attestation.
cosign verify --key k8s://tekton-chains/signing-secrets "${DOCKER_IMG}"
cosign verify-attestation --key k8s://tekton-chains/signing-secrets "${DOCKER_IMG}"
```

## Links

* Buildpacks: <https://buildpacks.io/>

## Dual backend setup

```bash
# From SSF root folder.
make setup-minikube setup-tekton-chains tekton-generate-keys # Removed chains setup from tekton task

# In another teminal.
./platform/05-minikube-registry-proxy.sh

# In chains repository.
ko apply -f config/

# Back to SSF root folder.
kubectl patch configmap chains-config -n tekton-chains --patch-file platform/components/tekton/chains/patch_config_dual_backend.yaml
make example-buildpacks

# Wait for completion.
# Ensure it has been signed.
tkn tr describe --last -o json | jq -r '.metadata.annotations["chains.tekton.dev/signed"]'

# Retrieve useful values.
IMAGE_URL=$(tkn tr describe --last -o  jsonpath='{.status.taskResults[?(@.name=="APP_IMAGE_URL")].value}')
TASKRUN_UID=$(tkn tr describe --last -o  jsonpath='{.metadata.uid}')

# Use cosign to verify OCI sig + att.
cosign verify --key k8s://tekton-chains/signing-secrets ${IMAGE_URL}
cosign verify-attestation --key k8s://tekton-chains/signing-secrets ${IMAGE_URL}

# Verify the sig + att stored the taskrun.
tkn tr describe --last -o  jsonpath='{.metadata.annotations["chains.tekton.dev/payload-taskrun-$TASKRUN_UID"]'
tkn tr describe --last -o  jsonpath='{.metadata.annotations["chains.tekton.dev/signature-taskrun-$TASKRUN_UID"]'
```
