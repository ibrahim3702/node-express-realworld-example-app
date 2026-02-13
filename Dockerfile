# Use the standard Node LTS image (Debian-based)
# This is bigger but has better compatibility than Alpine
FROM node:lts

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy source code
COPY . .

# Generate the Prisma client inside the container
# This will now create the "debian-openssl-3.0.x" engine
RUN npx prisma generate

# Start the app
CMD ["npm", "start"]