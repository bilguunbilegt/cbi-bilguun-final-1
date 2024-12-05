# Chicago Business Intelligence for Strategic Planning

This project uses microservices to collect and process data from the City of Chicago Data Portal for strategic planning and analysis.

## Microservices Overview

### 1. **Taxi Trips Data Collection**
   - Collects taxi trip data from the City of Chicago's datasets.
   - URL: `https://data.cityofchicago.org/resource/wrvz-psew.json`

### 2. **Community Area Unemployment Data Collection**
   - Collects unemployment and related public health statistics.
   - URL: `https://data.cityofchicago.org/resource/iqnk-2tcu.json`

### 3. **Building Permits Data Collection**
   - Collects building permits data from the city portal.
   - URL: `https://data.cityofchicago.org/resource/ydr8-5enu.json`

### 4. **COVID-19 Data Collection**
   - Collects weekly COVID-19 cases, rates, and test data.
   - URL: `https://data.cityofchicago.org/resource/yhhz-zm2v.json`

### 5. **CCVI Data Collection**
   - Collects Community Vulnerability Index (CCVI) data.
   - URL: `https://data.cityofchicago.org/resource/xhc6-88s9.json`

---

## Additional Components

### 1. **COVID-19 Forecasting and Alerts**
   - **Script**: `covid_forecasting.py`
   - **Description**:
     - Fetches historical COVID-19 case data from the database.
     - Preprocesses the data and trains a Prophet model to forecast cases for the next 14 days.
     - Classifies the forecasted cases into alert levels (`Low`, `Medium`, `High`).
     - Saves the forecast and alerts to the `forecasted_alerts` table in the database.
   - **Usage**:
     ```bash
     python covid_forecasting.py
     ```
   - **Outputs**:
     - A forecast table with dates, predicted cases, and alert levels.

### 2. **COVID-19 Dashboard**
   - **Script**: `covid_dashboard.py`
   - **Description**:
     - A web dashboard built using Dash and Plotly to visualize forecasted COVID-19 cases and their corresponding alert levels.
     - Displays an interactive line chart and alert level descriptions.
   - **Usage**:
     ```bash
     python covid_dashboard.py
     ```
   - **Dashboard**:
     - Access via `http://localhost:8000` (or the assigned deployment URL).

---

## Installation and Deployment Steps

### Prerequisites
- Google Cloud account.
- Installed: [gcloud CLI](https://cloud.google.com/sdk/docs/install), [Docker](https://www.docker.com/), Go, Python, and required Python libraries (`pandas`, `prophet`, `sqlalchemy`, `dash`, `plotly`).

### Steps to Deploy

1. **Setup Cloud SQL Database**
   - Create a PostgreSQL instance in Google Cloud SQL with the name `mypostgres`.
   - Create a database `chicago_business_intelligence`.

2. **Deploy pgAdmin**
   - Use the provided `cloudbuild.yaml` file:
     ```yaml
     - name: "gcr.io/cloud-builders/docker"
       args: ['pull', 'dpage/pgadmin4']
     ```
   - Deploy pgAdmin to Cloud Run to manage your database.

3. **Build and Deploy Go Microservice**
   - Navigate to the project directory.
   - Build and push the Docker image:
     ```bash
     docker build -t gcr.io/<PROJECT-ID>/go-microservice .
     docker push gcr.io/<PROJECT-ID>/go-microservice
     ```
   - Deploy the microservice to Cloud Run:
     ```bash
     gcloud run deploy go-microservice \
       --image gcr.io/<PROJECT-ID>/go-microservice \
       --region us-central1 \
       --add-cloudsql-instances <PROJECT-ID>:us-central1:mypostgres \
       --platform managed \
       --port 8080 \
       --allow-unauthenticated
     ```

4. **Deploy Python Scripts**
   - Install dependencies for both scripts:
     ```bash
     pip install pandas prophet sqlalchemy dash plotly psycopg2
     ```
   - Run `covid_forecasting.py` to generate forecasts.
   - Deploy `covid_dashboard.py` to a hosting service like Google App Engine or run locally.

5. **Environment Variables**
   - Set the following environment variables for Python scripts and Cloud Run services:
     - `DB_USER=postgres`
     - `DB_PASSWORD=<your-db-password>`
     - `DB_NAME=chicago_business_intelligence`
     - `INSTANCE_CONNECTION_NAME=<PROJECT-ID>:us-central1:mypostgres`

---

## Running Locally

### Go Microservice
1. Clone the repository and navigate to the project folder.
2. Modify the database connection string in `main.go`:
   ```go
   db_connection := "user=postgres dbname=chicago_business_intelligence password=<your-password> host=localhost sslmode=disable port=5432"
   ```
3. Start the service:
   ```bash
   go run main.go
   ```
4. Access the service at `http://localhost:8080`.

### Python Scripts
1. Run `covid_forecasting.py` to forecast and save alert levels.
2. Run `covid_dashboard.py` to start the dashboard:
   ```bash
   python covid_dashboard.py
   ```
3. Open `http://localhost:8000` in your browser to view the dashboard.

---

## Notes
- Use pgAdmin for database management.
- Review and update the `cloudbuild.yaml`, `Dockerfile`, and Python scripts for your deployment requirements.
- Refer to Google Cloud's [troubleshooting guide](https://cloud.google.com/docs/troubleshooting) for assistance.

--- 
