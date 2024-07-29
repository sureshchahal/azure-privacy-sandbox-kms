# Stage 1: Use the base image from Dockerfile.base to build the application
ARG BASE_CCF_IMAGE=5.0.0-rc0-virtual
ARG ENVIRONMENT=production

# Use the base stage from Dockerfile.base
FROM kms.devcontainer AS build

# Copy the application code
COPY . /kms

# Set the working directory
WORKDIR /kms

# Set up the Python environment, install Node.js dependencies, and build the project
RUN /kms/scripts/set_python_env.sh && npm install && make build
RUN ls -la .

# Stage 2: Create the production container
FROM mcr.microsoft.com/ccf/app/run:${BASE_CCF_IMAGE}  AS production

# Install Python and other necessary packages
#RUN apk add --no-cache python3 py3-pip bash coreutils
RUN  apt-get update && apt-get install --fix-missing python3.8-venv -y

# Set the working directory
WORKDIR /kms
RUN python3.8 -m venv .venv_ccf_sandbox  && /bin/bash -c "source .venv_ccf_sandbox/bin/activate"

# Copy the built artifacts from the build stage
COPY --from=build /kms/dist /kms/dist
COPY --from=build /kms/package.json /kms/package.json
COPY --from=build /kms/package-lock.json /kms/package-lock.json
COPY --from=build /kms/scripts/set_python_env.sh /kms/set_python_env.sh
COPY --from=build /opt/ccf_virtual/bin /opt/ccf_virtual/bin
COPY --from=build /kms/governance/constitution/kms_actions.js /kms
COPY --from=build /kms/requirements.txt /kms

RUN echo "virtual" > /opt/ccf_virtual/bin/PLATFORM
RUN echo "virtual" > /kms/PLATFORM
RUN mkdir /share && mkdir /share/VERSION_LONG && echo "virtual" > /share/VERSION_LONG/PLATFORM 
RUN ls -la

# Ensure /opt/ccf_virtual/bin is part of the PATH
ENV PATH="/opt/ccf_virtual/bin:${PATH}"

# Install only production dependencies
#RUN npm install --only=production
# Create and activate the virtual environment, then install the ccf package
#RUN python3.8 -m venv /opt/ccf_virtual/.venv_ccf_sandbox && \
#    /bin/bash -c "source /opt/ccf_virtual/.venv_ccf_sandbox/bin/activate && pip install -e /opt/ccf_virtual/python/"

# Change to the directory where sandbox.sh is located and run it
#WORKDIR /opt/ccf_virtual/bin

#CMD ["./sandbox.sh"]
# Install PIP packages. The list can probably be reduced for production.
RUN apt-get update && apt-get install --fix-missing python3.8-venv python3-pip  git -y
RUN /bin/bash -c "source /opt/ccf_virtual/.venv_ccf_sandbox/bin/activate"
RUN pip install -U -r /kms/requirements.txt

# Command to run the application
CMD ["tail", "-f", "/dev/null"]
#CMD ["/opt/ccf_virtual/bin/sandbox.sh --js-app-bundle ./dist/ --initial-member-count 1 --initial-user-count 1 --constitution ./kms_actions.js -v --http2"]