FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG Ngrok
ARG Password
ARG re

# Install required tools
RUN Invoke-WebRequest -Uri https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip -OutFile ngrok.zip -UseBasicParsing; \
    Expand-Archive ngrok.zip -DestinationPath C:\ngrok; \
    Remove-Item -Path ngrok.zip -Force

# Configure SSH
RUN Set-Service -Name sshd -StartupType 'Automatic'; \
    Start-Service sshd; \
    New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -PropertyType String -Force

# Set root password
RUN net user root ${Password}

# Create ngrok startup script
RUN echo ".\\ngrok\\ngrok.exe config authtoken ${Ngrok}" >> C:\1.bat; \
    echo ".\\ngrok\\ngrok.exe tcp 22 --region ${re}" >> C:\1.bat; \
    echo "C:\\Windows\\System32\\OpenSSH\\sshd.exe" >> C:\1.bat

# Expose ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Start ngrok and SSH
CMD ["cmd.exe", "/C", "C:\\1.bat"]
