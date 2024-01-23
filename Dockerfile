FROM node:16

# Install dependencies required by nvm and yarn
RUN apt-get update && \
    apt-get install -y curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y yarn

# Install nvm
ENV NVM_DIR /usr/local/nvm
RUN mkdir -p $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | NVM_DIR=$NVM_DIR bash

# Add nvm to PATH
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Use a separate RUN command to install Node using nvm
#RUN . $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use $NODE_VERSION

# Create the nvm_cmd.sh script
RUN echo "#!/bin/bash" > /usr/local/bin/nvm_cmd.sh && \
    echo "source /usr/local/nvm/nvm.sh" >> /usr/local/bin/nvm_cmd.sh && \
    echo 'nvm "$@"' >> /usr/local/bin/nvm_cmd.sh && \
    chmod +x /usr/local/bin/nvm_cmd.sh

# Add nvm.sh to .bashrc for later user
RUN echo "export NVM_DIR=$NVM_DIR" >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# Set working directory
WORKDIR /usr/local/nvm

# Confirm installation
RUN . $NVM_DIR/nvm.sh && nvm use $NODE_VERSION && node -v && npm -v && yarn -v
RUN . $NVM_DIR/nvm.sh && nvm current

# Add a health check for sanity check
HEALTHCHECK --interval=30s CMD node -v || exit 1

# Set the entrypoint to NVM's node
ENTRYPOINT ["/bin/bash"]
