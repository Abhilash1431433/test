# Use a Windows Server Core image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set working directory to C:\
WORKDIR C:\

# Download and install chocolatey package manager
RUN powershell.exe -Command Set-ExecutionPolicy Bypass -Scope Process -Force; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install required tools
RUN choco install -y git ngrok rdcman.portable

# Configure ngrok
ARG NgrokAuthToken
ENV NGROK_AUTH_TOKEN=${NgrokAuthToken}
RUN ngrok authtoken %NGROK_AUTH_TOKEN%

# Expose ngrok port and RDP port
EXPOSE 4040 3389

# Set the ngrok configuration and start ngrok
CMD ["powershell.exe", "-Command", "ngrok tcp --region=us 3389"]


