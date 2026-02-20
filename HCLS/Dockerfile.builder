# Use Ubuntu as the base for the builder
FROM rockylinux:9.3.20231119

# Install dependencies for Apptainer
RUN dnf install -y epel-release

# Install Apptainer from the official PPA
RUN dnf install -y apptainer

# Set the working directory
WORKDIR /workspace
ENTRYPOINT ["apptainer"]
