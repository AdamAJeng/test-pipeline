FROM node:23

# Install required tools
RUN apt-get update && \
    apt-get install -y jq dos2unix && \
    npm install -g @testim/testim-cli commander xunit-viewer

# Set working directory
WORKDIR /app

# Copy all files into the container
COPY . .

# Convert script line endings if needed
RUN dos2unix run-tests-on-grid.sh

# Make the script executable
RUN chmod +x run-tests-on-grid.sh

# Set default command
CMD ["./run-tests-on-grid.sh"]
