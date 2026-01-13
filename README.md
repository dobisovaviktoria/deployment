# Grocery App

## Author
- Viktória Dobišová

---

## Technologies Used

- Java 17
- Spring Boot
- Gradle
- PostgreSQL
- Docker & Docker Compose
- Nginx
- Shell scripting
- TLS Certificates
- Docker Secrets

---

## Quick Start - Local Deployment

1. After downloading the project from git, edit your hosts file to map the domain locally:
   
On Windows, open:

```
C:\Windows\System32\drivers\etc\hosts
```

Add the following line (you need admin rights):

```
127.0.0.1       groceryappvd.duckdns.org
```

2. Make sure your Docker Desktop is running
3. From the root of the project folder, run:

```
docker compose up -d
```

4. Visit: https://groceryappvd.duckdns.org

## Quick Start - Azure Deployment

1. Ensure the hosts file line is commented out:

```
#	127.0.0.1       groceryappvd.duckdns.org
```

2. Generate an SSH key (if not already created):

```
ssh-keygen -t ed25519 -f ~/.ssh/infra3_key
```

2. Clone the project into the linux environment:

```
git clone https://gitlab.com/kdg-ti/infrastructure-3/2024-25/acs201/viktoria-dobisova.git
```

3. Make the init script executable:

```
chmod +x ./viktoria-dobisova/azure/init.sh
```

4. Run the init script:

```
./viktoria-dobisova/azure/init.sh
```

5. Copy the project to the new virtual machine:

```
scp -i ~/.ssh/infra3_key -r ./viktoria-dobisova student@groceryappvd.duckdns.org:~
```

6. SSH into the virtual machine:

```
ssh -i ~/.ssh/infra3_key student@groceryappvd.duckdns.org
```

7. Update docker-compose.yml:

- update certificate link (no longer using self-signed certificates) 
- secrets no longer work

```
 vim viktoria-dobisova/docker-compose.yml
```

Changes affect the following 3 services:

```
db-vd:
        image: postgres:17.2-alpine
        restart: always
        environment:
            POSTGRES_DB: 'infra_project'
            POSTGRES_USER: spring
            POSTGRES_PASSWORD: spring
        volumes:
            - db-data-vd:/var/lib/postgresql/data
        networks:
            - default
```

```
groceryapp-vd:
        build: .
        ports:
            - "8080:8080"
        depends_on:
            - db-vd
        environment:
            SPRING_DATASOURCE_URL: jdbc:postgresql://db-vd:5432/infra_project
            SPRING_DATASOURCE_USERNAME: spring
            SPRING_DATASOURCE_PASSWORD: spring
        networks:
            - default
```

```
proxy-vd:
        image: nginx:alpine
        volumes:
            - /etc/letsencrypt/live/groceryappvd.duckdns.org/fullchain.pem:/etc/cert/fullchain.pem:ro
            - /etc/letsencrypt/live/groceryappvd.duckdns.org/privkey.pem:/etc/cert/privkey.pem:ro
            - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf
            - ./frontend:/usr/share/nginx/html
        depends_on:
            - groceryapp-vd
        ports:
            - "80:80"
            - "443:443"
        networks:
            - default
```

8. Navigate to the app folder:

```
cd viktoria-dobisova/
```

9. Start the services:

```
docker compose up -d
```

10. Visit: https://groceryappvd.duckdns.org


## Note 
 
- You can only issue 5 certs/week per domain (groceryappvd.duckdns.org). Avoid re-running Certbot unnecessarily.
