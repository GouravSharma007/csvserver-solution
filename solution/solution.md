# Csvserver Solution
If you are using Window system instead of Linux then you can Follow these instructions.
### Step 1: Installing Docker on Windows
1. **Download Docker Desktop for Windows** from the [Docker website](https://www.docker.com/products/docker-desktop).
2. **Install Docker Desktop**:
   - Run the installer and follow the prompts.
  
3. **Open Docker Desktop** and make sure it is running.

### Step 2: Setting Up WSL (Windows Subsystem for Linux)
1. **Install WSL**:
   - Open **PowerShell** as an administrator and run:
     ```bash
     wsl --install
     ```
   - This installs WSL 2 and a default Linux distribution (e.g., Ubuntu).
2. **Verify WSL version**:
   ```bash
   wsl --version 
   ```
   Ensure your distribution is set to WSL 2.

3. **Set WSL 2 as the default version**:
   ```bash
   wsl --set-default-version 2
   ```

### Step 3: Connecting WSL with VS Code
1. **Install the Remote - WSL extension**:
   - Open VS Code, go to **Extensions**, and search for "Remote - WSL" by Microsoft.
   - Install the extension.
2. **Open your WSL distribution** in VS Code:
   - Run `wsl` in the command line to enter the Linux terminal.
   - Navigate to your project directory and run:
     ```bash
     code .
     ```
   - It will open the VS Code and now you can do all the work on VS Code Terminal.

## Part 1

### Step 1: Running the CSV Server Docker Container
1. **Pull the Docker image**:
   ```bash
   docker pull infracloudio/csvserver:latest
   ```

2. **Run the container in detached mode**:
   ```bash
   docker run -d --name csvserver infracloudio/csvserver:latest
   ```

3. **Check if the container is running**:
   ```bash
   docker ps
   ```

4. **View logs for any error**:
   ```bash
   docker logs csvserver
   ```
5.  

### Step 2: Creating `inputFile`
1. **Create `gencsv.sh` script**:
   ```bash
   vi gencsv.sh
   ```
   Add the following content:
   ```bash
   #!/bin/bash
   start=$1
   end=$2

   if [ -z "$start" ] || [ -z "$end" ]; then
       echo "Usage: $0 <start> <end>"
       exit 1
   fi

   file="inputFile"
   rm -f $file

   for ((i=$start; i<=$end; i++)); do
       echo "$i, $((RANDOM % 1000))" >> $file
   done
   ```

2. **Make the script executable**:
   ```bash
   chmod +x gencsv.sh
   ```

3. **Generate `inputFile`**:
   ```bash
   ./gencsv.sh 2 8
   ```
   - Here 2 and 8 are the start and end number

### Step 3: Run the Container with the Input File and Environment Variable
1. **Run the container with `inputFile` and an environment variable**:
   ```bash
   docker run -d --name csvserver -v "$(pwd)/inputFile:/csvserver/inputdata" -p 9393:9300 -e CSVSERVER_BORDER=Orange infracloudio/csvserver:latest
   ```
   - Instead of writing the path of the file you can use $(pwd)

2. **If you got any error like this**:
    ```
   error while reading the file "/csvserver/inputdata": open /csvserver/inputdata: no such file or directory
   ```
    - This error occur because of the name inputfile in the system and inputdata in docker container 
   
3. **Use this commond**:
    ```bash
   docker cp inputFile csvserver:/csvserver/inputdata
   ```
    - Open the Docker Desktop and Navigate to csvserver container<File<csvserver<inputdata
    - If it is modified then
      
4. **Use this command to check if the container is running**:
   ```bash
   docker ps
   ```

5. **Access the application**:
   - Navigate to [http://localhost:9393](http://localhost:9393).

### Step 4: Logs and Outputs
- Run the command to save container output:
   ```bash
   curl -o part-1-output http://localhost:9393/raw
   ```
- Log output:
   ```bash
   docker logs csvserver > part-1-logs
   ```

## Part 2: Docker Compose Setup

### Step 1: Stop and remove containers using the following commands
 ```bash
docker stop csvserver
docker rm csvserver
 ```

### Step 2: Create `docker-compose.yaml` file
```yaml
version: '3.8'

services:
  csvserver:
    image: infracloudio/csvserver:latest
    container_name: csvserver
    volumes:
      - ./inputFile:/csvserver/inputdata
    env_file:
      - csvserver.env
    ports:
      - "9300:9300"
```

### Step 2: Create `csvserver.env` file
```bash
touch csvserver.env
```
Or you can create the file manually by clicking on New file in VS Code

### Step 3: Run with Docker Compose
```bash
docker-compose up -d
```
### Step 4: Saved the change and puch to Github
```bash
git status
git add .
git commit -m"Name"
git push
```

## Part 3: Adding Prometheus

### Step 1:Deleted any containers running from the last part
```bash
docker-compose down
```

### Step 2: Update `docker-compose.yaml`
```yaml
version: '3.8'

services:
  csvserver:
    image: infracloudio/csvserver:latest
    container_name: csvserver
    volumes:
      - ./inputFile:/csvserver/inputdata
    env_file:
      - csvserver.env
    ports:
      - "9300:9300"

  prometheus:
    image: prom/prometheus:v2.45.2
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
```

### Step 3: Create `prometheus.yml`
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'csvserver'
    static_configs:
      - targets: ['csvserver:9300']
```

### Step 4: Run and Verify
```bash
docker-compose up -d
```
- Access Prometheus at [http://localhost:9090](http://localhost:9090).
- Type `csvserver_records` in querybox and click on execute.
- Switch to the Graph tab to visualize the metric.
- The ouput will be the straight line at 7 on graph.
