# 🏥 Spring PetClinic CI/CD Automation

## 🚀 Mission Statement

This project aims to implement a robust CI/CD pipeline for the Spring PetClinic application using two popular automation tools: **Jenkins** and **GitHub Actions**. The goal is to automate the entire software lifecycle — from code compilation and testing to quality analysis, containerization, and deployment — ensuring faster delivery, higher code quality, and seamless integration.

---

## 🧰 Technologies Used

- **Spring PetClinic** – Java-based web application
- **Jenkins** – Self-hosted CI/CD automation server
- **GitHub Actions** – Cloud-native CI/CD platform
- **Maven** – Build and dependency management
- **SonarQube** – Code quality and security analysis
- **Docker & Docker Compose** – Containerization and deployment
- **Nexus** – Docker image registry

---

## 🛠️ Jenkins Pipeline Overview

The Jenkins pipeline is defined using a declarative `Jenkinsfile`. Here's a breakdown of each stage:

### 🔧 Tools & Environment Setup
- Uses JDK 17 and Maven 3.8.
- Environment variables for SonarQube, Nexus, Docker image tagging, and credentials.

### 📥 Checkout
- Pulls the latest code from GitHub using `checkout scm`.

### 🏗️ Build
- Runs `mvn clean compile` to compile the Java code.

### 🧪 Test
- Executes unit tests via `mvn test`.
- Publishes JUnit results to Jenkins UI.

### 🔍 SonarQube Analysis
- Performs static code analysis using SonarQube.
- Authenticates using a secure token.

### ✅ Quality Gate
- Waits for SonarQube's approval before proceeding.
- Aborts pipeline if quality gate fails.

### 🐳 Docker Image Build
- Builds Docker image tagged with build number and `latest`.

### 📦 Push to Nexus
- Logs into Nexus using credentials.
- Pushes both versioned and `latest` Docker images.

### 🚚 Deploy
- Uses Docker Compose to stop and redeploy the application.
- Supports local and remote deployment via SSH.

### 🧹 Post Actions
- Cleans up Docker resources.
- Logs success or failure messages.

---

## 🧪 GitHub Actions Workflow Overview

The GitHub Actions workflow is defined in `.github/workflows/petclinic.yml`. It consists of three jobs:

### 🔨 Build
- Triggered on push or pull request to `main`.
- Sets up JDK 17 using `actions/setup-java`.
- Caches Maven dependencies.
- Compiles the code with `mvn clean compile`.

### 🧪 Test
- Depends on the build job.
- Runs unit tests and uploads test reports using `actions/upload-artifact`.

### 🔍 SonarQube Analysis
- Depends on the test job.
- Performs SonarQube scan with credentials from GitHub Secrets.
- Uses `fetch-depth: 0` for proper diff analysis.

---

## 🔍 Jenkins vs GitHub Actions: Key Differences

| Feature               | Jenkins                                      | GitHub Actions                                |
|----------------------|----------------------------------------------|-----------------------------------------------|
| Hosting              | Self-hosted                                  | Cloud-hosted by GitHub                        |
| Configuration        | Declarative `Jenkinsfile`                    | YAML-based workflow files                     |
| Scalability          | Requires manual agent setup                  | Scales automatically with GitHub runners      |
| Secrets Management   | Jenkins Credentials                          | GitHub Secrets                                |
| UI & Monitoring      | Rich dashboard with plugins                  | Integrated with GitHub UI                     |
| Flexibility          | Highly customizable with plugins             | Simpler setup, tightly integrated with GitHub |
| Deployment           | Docker Compose, SSH                          | Requires external deployment setup            |

---

## 📌 Task Description

My task was to:
1. **Design and implement** a complete CI/CD pipeline for Spring PetClinic using Jenkins and GitHub Actions.
2. **Integrate SonarQube** for code quality checks.
3. **Containerize the application** using Docker.
4. **Push Docker images** to a Nexus registry.
5. **Deploy the application** using Docker Compose.
6. **Compare and document** the differences between Jenkins and GitHub Actions in terms of setup, flexibility, and scalability.

This dual-pipeline approach ensures redundancy, flexibility, and a deeper understanding of CI/CD tooling in modern DevOps environments.

---

## 📣 Final Notes

- Jenkins is ideal for complex, customizable pipelines in enterprise environments.
- GitHub Actions is perfect for quick setups and tight GitHub integration.
- Both pipelines achieve the same goal: reliable, automated delivery of high-quality software.

Feel free to explore, modify, and extend these pipelines to suit your deployment needs!
