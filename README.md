# DevOps Assessment - Full-Stack Application Deployment

A production-ready, containerized full-stack application with comprehensive monitoring, CI/CD pipeline, and HTTPS security.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS EC2 Instance                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐                                                   │
│  │  Nginx   │ ←── HTTPS (Port 443) / HTTP (Port 80)            │
│  │  Proxy   │                                                   │
│  └────┬─────┘                                                   │
│       │                                                         │
│  ┌────┴────────────────────────────────────────────────┐       │
│  │                                                      │       │
│  ▼                    ▼                    ▼           │       │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐         │       │
│  │ Frontend │    │ Backend  │    │ Grafana  │         │       │
│  │  (React) │    │(Node.js) │    │ (3001)   │         │       │
│  │  (3000)  │    │ (5000)   │    │          │         │       │
│  └──────────┘    └────┬─────┘    └────┬─────┘         │       │
│                       │               │                │       │
│                       ▼               ▼                │       │
│                  ┌──────────┐    ┌──────────┐         │       │
│                  │Prometheus│◄───┤  Alert   │         │       │
│                  │  (9090)  │    │ Manager  │         │       │
│                  └────┬─────┘    │  (9093)  │         │       │
│                       │          └──────────┘         │       │
│                       ▼                               │       │
│                  ┌──────────┐                         │       │
│                  │  Node    │                         │       │
│                  │ Exporter │                         │       │
│                  │  (9100)  │                         │       │
│                  └──────────┘                         │       │
└─────────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Component | Technology |
|-----------|------------|
| Frontend | React.js |
| Backend | Node.js + Express |
| Containerization | Docker + Docker Compose |
| Reverse Proxy | Nginx |
| SSL/TLS | Let's Encrypt (Certbot) |
| CI/CD | Jenkins |
| Metrics Collection | Prometheus |
| Visualization | Grafana |
| Alerting | Alertmanager |
| System Metrics | Node Exporter |
| Cloud | AWS EC2 |

## Project Structure

```
devops-assessment/
├── backend/
│   ├── server.js          # Express server with Prometheus metrics
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
├── frontend/
│   ├── src/
│   │   ├── App.js         # React application
│   │   └── index.js
│   ├── public/
│   │   └── index.html
│   ├── package.json
│   ├── Dockerfile
│   ├── nginx.conf
│   └── .dockerignore
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus.yml     # Prometheus configuration
│   │   └── alert_rules.yml    # Alert rules
│   ├── alertmanager/
│   │   └── alertmanager.yml   # Alertmanager configuration
│   └── grafana/
│       └── provisioning/
│           └── datasources/
│               └── datasources.yml
├── nginx/
│   └── nginx.conf         # Reverse proxy configuration
├── docker-compose.yml     # Full stack orchestration
├── Jenkinsfile           # CI/CD pipeline
├── .gitignore
├── .env.example
└── README.md
```

## Quick Start (Local Development)

### Prerequisites

- Docker and Docker Compose installed
- Git installed

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/VP-Dexxtro/devops-assessment.git
   cd devops-assessment
   ```

2. **Start all services**
   ```bash
   docker-compose up -d --build
   ```

3. **Verify services are running**
   ```bash
   docker-compose ps
   ```

4. **Access the applications**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000/api
   - Backend Health: http://localhost:5000/health
   - Backend Metrics: http://localhost:5000/metrics
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3001 (admin/admin123)
   - Alertmanager: http://localhost:9093

## AWS EC2 Deployment

### Step 1: Launch EC2 Instance

1. Go to AWS Console → EC2 → Launch Instance
2. **AMI**: Ubuntu 22.04 LTS
3. **Instance Type**: t2.medium (2 vCPU, 4GB RAM) recommended
4. **Security Group** - Allow inbound:
   - SSH (22) - Your IP
   - HTTP (80) - Anywhere
   - HTTPS (443) - Anywhere
   - Custom TCP 3000, 5000, 9090, 9093, 3001 - Anywhere (for testing)
5. Create/select a key pair and download the `.pem` file

### Step 2: Connect to EC2

```bash
# Set permissions on key file
chmod 400 your-key.pem

# Connect via SSH
ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>
```

### Step 3: Install Docker

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io docker-compose git

# Add user to docker group
sudo usermod -aG docker ubuntu

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Logout and login for group changes to take effect
exit
```

Reconnect via SSH.

### Step 4: Deploy Application

```bash
# Clone repository
git clone https://github.com/VP-Dexxtro/devops-assessment.git
cd devops-assessment

# Build and start all services
docker-compose up -d --build

# Verify all containers are running
docker-compose ps
```

### Step 5: Configure Domain DNS

In your domain registrar (GoDaddy, Namecheap, Route53, etc.):

1. Add an A Record:
   - **Type**: A
   - **Name**: @ (or subdomain like 'app')
   - **Value**: `<EC2-PUBLIC-IP>`
   - **TTL**: 300

2. Wait for DNS propagation (5-30 minutes)

### Step 6: Enable HTTPS with Certbot

```bash
# Install Certbot
sudo apt install -y certbot

# Stop nginx container temporarily
docker-compose stop nginx

# Get SSL certificate
sudo certbot certonly --standalone -d aboli05.duckdns.org

# Update nginx.conf to enable HTTPS
# (Uncomment the HTTPS server block and update domain name)

# Restart nginx
docker-compose up -d nginx
```

## Jenkins CI/CD Setup

### Step 1: Install Jenkins

```bash
# Install Java
sudo apt install -y openjdk-11-jdk

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step 2: Configure Jenkins

1. Access Jenkins at `http://<EC2-PUBLIC-IP>:8080`
2. Enter the initial admin password
3. Install suggested plugins
4. Create admin user
5. Add Docker Hub credentials:
   - Go to Manage Jenkins → Credentials
   - Add credentials with ID: `dockerhub-credentials`

### Step 3: Create Pipeline

1. New Item → Pipeline
2. Configure:
   - **Repository URL**: Your GitHub repo
   - **Branch**: main
   - **Script Path**: Jenkinsfile
3. Build Now

## Monitoring Stack

### Prometheus

- **URL**: http://localhost:9090
- **Scrape Targets**:
  - Backend application metrics (`/metrics`)
  - Node Exporter (system metrics)
  - Prometheus self-monitoring

### Grafana

- **URL**: http://localhost:3001
- **Default Credentials**: admin / admin123
- **Pre-configured**: Prometheus data source

**Recommended Dashboards:**
1. Import Dashboard ID `1860` - Node Exporter Full
2. Import Dashboard ID `11159` - Node.js Application Dashboard

### Alertmanager

- **URL**: http://localhost:9093
- **Configured Alerts**:
  1. **HighMemoryUsage**: Triggers when memory usage > 80%
  2. **BackendDown**: Triggers when backend is unreachable for 1 minute
  3. **HighCPUUsage**: Triggers when CPU usage > 80%
  4. **LowDiskSpace**: Triggers when disk space < 20%
  5. **NodeExporterDown**: Triggers when Node Exporter is down

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api` | GET | Main API endpoint |
| `/health` | GET | Health check endpoint |
| `/metrics` | GET | Prometheus metrics |

## Useful Commands

```bash
# View all containers
docker-compose ps

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend

# Restart specific service
docker-compose restart backend

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild and restart
docker-compose up -d --build

# SSH into container
docker exec -it backend sh
```

## Troubleshooting

### Container not starting
```bash
docker-compose logs <service-name>
```

### Port already in use
```bash
sudo lsof -i :<port>
sudo kill -9 <PID>
```

### Check Prometheus targets
Visit http://localhost:9090/targets to verify scrape targets are healthy.

### Grafana can't connect to Prometheus
Ensure the Prometheus datasource URL is set to `http://prometheus:9090` (Docker network name).

## Security Considerations

- Never commit secrets or credentials to GitHub
- Use `.env` files for sensitive configuration
- Restrict Security Group access in production
- Regularly update Docker images
- Use strong passwords for Grafana and other services

## Submission Checklist

- [ ] GitHub repository with all configuration files
- [ ] Public domain URL with HTTPS enabled
- [ ] Jenkins pipeline screenshot/logs
- [ ] Grafana dashboard screenshot
- [ ] Alertmanager configuration file included
- [ ] README.md with deployment steps

## License

This project is created for the Waybeyond Tech DevOps Assessment.
