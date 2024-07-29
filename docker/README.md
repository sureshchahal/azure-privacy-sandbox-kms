# devcontainer
docker build -t kms.devcontainer -f .devcontainer/Dockerfile.devcontainer .
# prod container
docker build -t kms.prod -f docker/Dockerfile . --no-cache
# run
docker run -it --rm kms.prod
for the moment remove ../ in sandbox.sh
attach shell
source /opt/ccf_virtual/.venv_ccf_sandbox/bin/activate