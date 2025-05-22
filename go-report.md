
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>api: Go Coverage Report</title>
		<style>
			body {
				background: black;
				color: rgb(80, 80, 80);
			}
			body, pre, #legend span {
				font-family: Menlo, monospace;
				font-weight: bold;
			}
			#topbar {
				background: black;
				position: fixed;
				top: 0; left: 0; right: 0;
				height: 42px;
				border-bottom: 1px solid rgb(80, 80, 80);
			}
			#content {
				margin-top: 50px;
			}
			#nav, #legend {
				float: left;
				margin-left: 10px;
			}
			#legend {
				margin-top: 12px;
			}
			#nav {
				margin-top: 10px;
			}
			#legend span {
				margin: 0 5px;
			}
			.cov0 { color: rgb(192, 0, 0) }
.cov1 { color: rgb(128, 128, 128) }
.cov2 { color: rgb(116, 140, 131) }
.cov3 { color: rgb(104, 152, 134) }
.cov4 { color: rgb(92, 164, 137) }
.cov5 { color: rgb(80, 176, 140) }
.cov6 { color: rgb(68, 188, 143) }
.cov7 { color: rgb(56, 200, 146) }
.cov8 { color: rgb(44, 212, 149) }
.cov9 { color: rgb(32, 224, 152) }
.cov10 { color: rgb(20, 236, 155) }

		</style>
	</head>
	<body>
		<div id="topbar">
			<div id="nav">
				<select id="files">
				
				<option value="file0">employee-api/api/api.go (28.3%)</option>
				
				<option value="file1">employee-api/api/health.go (66.7%)</option>
				
				<option value="file2">employee-api/client/redis.go (100.0%)</option>
				
				<option value="file3">employee-api/client/scylladb.go (100.0%)</option>
				
				<option value="file4">employee-api/config/viper.go (80.0%)</option>
				
				<option value="file5">employee-api/docs/docs.go (0.0%)</option>
				
				<option value="file6">employee-api/main.go (0.0%)</option>
				
				<option value="file7">employee-api/middleware/logging.go (100.0%)</option>
				
				<option value="file8">employee-api/routes/routes.go (100.0%)</option>
				
				</select>
			</div>
			<div id="legend">
				<span>not tracked</span>
			
				<span class="cov0">not covered</span>
				<span class="cov8">covered</span>
			
			</div>
		</div>
		<div id="content">
		
		<pre class="file" id="file0" style="display: none">package api

import (
        "employee-api/client"
        "employee-api/config"
        "employee-api/model"
        "encoding/json"
        "github.com/gin-gonic/gin"
        redis "github.com/redis/go-redis/v9"
        "github.com/sirupsen/logrus"
        "net/http"
        "time"
)

var (
        redisEnabled = config.ReadConfigAndProperty().Redis.Enabled
)

// @Summary ReadEmployeesDesignation is a method to read all employee designation
// @Schemes http
// @Description Read all employee location data from database
// @Tags employee
// @Accept json
// @Produce json
// @Success 200 {object} model.Designation
// @Router /search/designation [get]
// ReadEmployeesDesignation is a method to read all employee location
func ReadEmployeesDesignation(c *gin.Context) <span class="cov8" title="1">{
        var employee model.Employee
        var designationResponse model.Designation
        var redisError error
        var redisData string
        if redisEnabled </span><span class="cov0" title="0">{
                redisData, redisError = client.CreateRedisClient().HGet(ctx, "employee", "designation").Result()
                if redisError != nil </span><span class="cov0" title="0">{
                        logrus.Warnf("Unable to read data from Redis %v", redisError)
                }</span>
                <span class="cov0" title="0">_ = json.Unmarshal([]byte(redisData), &amp;designationResponse)
                if redisError == nil </span><span class="cov0" title="0">{
                        logrus.Infof("Successfully fetched the data for designation from the Redis")
                        c.JSON(http.StatusOK, designationResponse)
                        return
                }</span>
        }
        <span class="cov8" title="1">scyllaClient, err := client.CreateScyllaDBClient()
        if err != nil </span><span class="cov8" title="1">{
                logrus.Errorf("Error in reading data from scylladb: %v", err)
                errorResponse(c, "Cannot read data from the system, request failure")
                return
        }</span>
        <span class="cov0" title="0">designation := make(map[string]int)
        data := scyllaClient.Query("SELECT designation FROM employee_info").Iter()
        for data.Scan(&amp;employee.Designation) </span><span class="cov0" title="0">{
                _, exist := designation[employee.Designation]
                if exist </span><span class="cov0" title="0">{
                        designation[employee.Designation] += 1
                }</span> else<span class="cov0" title="0"> {
                        designation[employee.Designation] = 1
                }</span>
        }
        <span class="cov0" title="0">jsonData, err := json.Marshal(designation)
        if err != nil </span><span class="cov0" title="0">{
                logrus.Errorf("Error in reading data from scylladb: %v", err)
                errorResponse(c, "Cannot read data from the system, request failure")
                return
        }</span>
        <span class="cov0" title="0">if redisEnabled &amp;&amp; redisError == redis.Nil </span><span class="cov0" title="0">{
                writeinRedis("designation", string(jsonData))
        }</span>
        <span class="cov0" title="0">logrus.Infof("Successfully fetched the data for all designation from the ScyllaDB")
        json.Unmarshal(jsonData, &amp;designationResponse)
        c.JSON(http.StatusOK, designationResponse)
        return</span>
}

// @Summary ReadEmployeesLocation is a method to read all employee location
// @Schemes http
// @Description Read all employee location data from database
// @Tags employee
// @Accept json
// @Produce json
// @Success 200 {object} model.Location
// @Router /search/location [get]
// ReadEmployeesLocation is a method to read all employee location
func ReadEmployeesLocation(c *gin.Context) <span class="cov8" title="1">{
        var employee model.Employee
        var locationResponse model.Location
        var redisError error
        var redisData string
        if redisEnabled </span><span class="cov0" title="0">{
                redisData, redisError = client.CreateRedisClient().HGet(ctx, "employee", "location").Result()
                if redisError != nil </span><span class="cov0" title="0">{
                        logrus.Warnf("Unable to read data from Redis %v", redisError)
                }</span>
                <span class="cov0" title="0">json.Unmarshal([]byte(redisData), &amp;locationResponse)
                if redisError == nil </span><span class="cov0" title="0">{
                        logrus.Infof("Successfully fetched the data for location from the Redis")
                        c.JSON(http.StatusOK, locationResponse)
                        return
                }</span>
        }
        <span class="cov8" title="1">scyllaClient, err := client.CreateScyllaDBClient()
        if err != nil </span><span class="cov8" title="1">{
                logrus.Errorf("Error in reading data from scylladb: %v", err)
                errorResponse(c, "Cannot read data from the system, request failure")
                return
        }</span>
        <span class="cov0" title="0">location := make(map[string]int)
        data := scyllaClient.Query("SELECT office_location FROM employee_info").Iter()
        for data.Scan(&amp;employee.OfficeLocation) </span><span class="cov0" title="0">{
                _, exist := location[employee.OfficeLocation]
                if exist </span><span class="cov0" title="0">{
                        location[employee.OfficeLocation] += 1
                }</span> else<span class="cov0" title="0"> {
                        location[employee.OfficeLocation] = 1
                }</span>
        }
        <span class="cov0" title="0">jsonData, err := json.Marshal(location)
        if err != nil </span><span class="cov0" title="0">{
                logrus.Errorf("Error in reading data from scylladb: %v", err)
                errorResponse(c, "Cannot read data from the system, request failure")
                return
        }</span>
        <span class="cov0" title="0">if redisEnabled &amp;&amp; redisError == redis.Nil </span><span class="cov0" title="0">{
                writeinRedis("location", string(jsonData))
        }</span>
        <span class="cov0" title="0">logrus.Infof("Successfully fetched the data for all location from the ScyllaDB")
        json.Unmarshal(jsonData, &amp;locationResponse)
        c.JSON(http.StatusOK, locationResponse)
        return</span>
}

// @Summary ReadCompleteEmployeesData is a method to read all employee's information
// @Schemes http
// @Description Read all employee data from database
// @Tags employee
// @Accept json
// @Produce json
// @Success 200 {array} model.Employee
// @Router /search/all [get]
// ReadCompleteEmployeesData is a method to read all employee information
func ReadCompleteEmployeesData(c *gin.Context) <span class="cov8" title="1">{
        var employee model.Employee
        var response []model.Employee
        var redisError error
        var redisData string
        if redisEnabled </span><span class="cov0" title="0">{
                redisData, redisError = client.CreateRedisClient().HGet(ctx, "employee", "all_data").Result()
                if redisError != nil </span><span class="cov0" title="0">{
                        logrus.Warnf("Unable to read data from Redis %v", redisError)
                }</span>
                <span class="cov0" title="0">json.Unmarshal([]byte(redisData), &amp;response)
                if redisError == nil </span><span class="cov0" title="0">{
                        logrus.Infof("Successfully fetched the data for all employee from the Redis")
                        c.JSON(http.StatusOK, response)
                        return
                }</span>
        }
        <span class="cov8" title="1">scyllaClient, err := client.CreateScyllaDBClient()
        if err != nil </span><span class="cov8" title="1">{
                logrus.Errorf("Error in reading data from scylladb: %v", err)
                errorResponse(c, "Cannot read data from the system, request failure")
                return
        }</span>
        <span class="cov0" title="0">data := scyllaClient.Query("SELECT id, name, designation, department, joining_date, address, office_location, status, email, phone_number FROM employee_info").Iter()
        for data.Scan(&amp;employee.ID, &amp;employee.Name, &amp;employee.Designation, &amp;employee.Department, &amp;employee.JoiningDate, &amp;employee.Address, &amp;employee.OfficeLocation, &amp;employee.Status, &amp;employee.EmailID, &amp;employee.PhoneNumber) </span><span class="cov0" title="0">{
                response = append(response, employee)
        }</span>
        <span class="cov0" title="0">jsonData, err := json.Marshal(response)
        if err != nil </span><span class="cov0" title="0">{
                logrus.Errorf("Error in reading data from scylladb: %v", err)
                errorResponse(c, "Cannot read data from the system, request failure")
                return
        }</span>
        <span class="cov0" title="0">if redisEnabled &amp;&amp; redisError == redis.Nil </span><span class="cov0" title="0">{
                writeinRedis("all_data", string(jsonData))
        }</span>
        <span class="cov0" title="0">logrus.Infof("Successfully fetched the data for all employee from the ScyllaDB")
        c.JSON(http.StatusOK, response)</span>
}

// @Summary ReadEmployeeData is a method to read employee information
// @Schemes http
// @Description Read data from database
// @Tags employee
// @Accept json
// @Produce json
// @Param id query string true "User ID"
// @Success 200 {object} model.Employee
// @Router /search [get]
// ReadEmployeeData is a method to read employee information
func ReadEmployeeData(c *gin.Context) <span class="cov8" title="1">{
        var response model.Employee
        mapData := map[string]interface{}{}
        var redisError error
        var redisData string
        id, keyExists := c.GetQuery("id")
        if !keyExists </span><span class="cov8" title="1">{
                logrus.Errorf("Query request of data without params")
                errorResponse(c, "Unable to perform search operation, query params not defined")
                return
        }</span>
        <span class="cov0" title="0">if redisEnabled </span><span class="cov0" title="0">{
                redisData, redisError = client.CreateRedisClient().HGet(ctx, "employee", id).Result()
                if redisError != nil </span><span class="cov0" title="0">{
                        logrus.Warnf("Unable to read data from Redis %v", redisError)
                }</span>
                <span class="cov0" title="0">json.Unmarshal([]byte(redisData), &amp;response)
                if redisError == nil </span><span class="cov0" title="0">{
                        logrus.Infof("Successfully fetched the data for %s from the Redis", id)
                        c.JSON(http.StatusOK, response)
                        return
                }</span>
        }
        <span class="cov0" title="0">scyllaClient, err := client.CreateScyllaDBClient()
        if err != nil </span><span class="cov0" title="0">{
                logrus.Errorf("Error in reading data from scylladb: %v", err)
                errorResponse(c, "Cannot read data from the system, request failure")
                return
        }</span>
        <span class="cov0" title="0">data := scyllaClient.Query("SELECT * FROM employee_info where id = ?", id).Iter()
        for data.MapScan(mapData) </span><span class="cov0" title="0">{
                jsonData, err := json.Marshal(mapData)
                if err != nil </span><span class="cov0" title="0">{
                        logrus.Errorf("Error in reading data from scylladb: %v", err)
                        errorResponse(c, "Cannot read data from the system, request failure")
                        return
                }</span>
                <span class="cov0" title="0">if redisEnabled &amp;&amp; redisError == redis.Nil </span><span class="cov0" title="0">{
                        writeinRedis(id, string(jsonData))
                }</span>
                <span class="cov0" title="0">json.Unmarshal(jsonData, &amp;response)
                logrus.Infof("Successfully fetched the data for %s from the ScyllaDB", id)
                c.JSON(http.StatusOK, response)
                return</span>
        }
}

// @Summary CreateEmployeeData is a method to write employee information in database
// @Schemes http
// @Description Write data in database
// @Tags employee
// @Accept json
// @Produce json
// @Param employee body model.Employee true "Employee Data"
// @Success 200 {object} model.Employee
// @Router /create [post]
// CreateEmployeeData is a method to write employee information in database
func CreateEmployeeData(c *gin.Context) <span class="cov8" title="1">{
        var request model.Employee
        if err := c.BindJSON(&amp;request); err != nil </span><span class="cov0" title="0">{
                logrus.Errorf("Error parsing the request body in JSON: %v", err)
                errorResponse(c, "Unable to Bind JSON in defined format, seems malformed")
                return
        }</span>
        <span class="cov8" title="1">scyllaClient, err := client.CreateScyllaDBClient()
        if err != nil </span><span class="cov8" title="1">{
                logrus.Errorf("Error in writing data to scylladb: %v", err)
                errorResponse(c, "Cannot write data to the system, request failure")
                return
        }</span>
        <span class="cov0" title="0">defer scyllaClient.Close()
        date, err := time.Parse("2006-01-02", request.JoiningDate)
        if err != nil </span><span class="cov0" title="0">{
                logrus.Errorf("Error in writing data to scylladb: %v", err)
                errorResponse(c, "Cannot write data to the system, request failure")
                return
        }</span>
        <span class="cov0" title="0">queryString := "INSERT INTO employee_info(id, name, designation, department, joining_date, address, office_location, status, email, phone_number) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"

        if err := scyllaClient.Query(queryString,
                request.ID, request.Name, request.Designation, request.Department, date, request.Address, request.OfficeLocation, request.Status, request.EmailID, request.PhoneNumber).Exec(); err != nil </span><span class="cov0" title="0">{
                logrus.Errorf("Error in writing data to scylladb: %v", err)
                errorResponse(c, "Cannot write data to the system, request failure")
                return
        }</span>
        <span class="cov0" title="0">data := model.CustomMessage{
                Message: "Successfully created the data for the user",
        }
        logrus.Infof("Successfully created the employee record")
        c.JSON(http.StatusOK, data)</span>
}

// writeinRedis is a method to write the data in Redis cache
func writeinRedis(cacheKey, cacheValue string) <span class="cov0" title="0">{
        _, err := client.CreateRedisClient().HSet(ctx, "employee", cacheKey, cacheValue).Result()
        if err != nil </span><span class="cov0" title="0">{
                logrus.Errorf("Error in reading writing data to Redis: %v", err)
        }</span>
}

// errorResponse is a method to return bad http code in Gin
func errorResponse(c *gin.Context, err string) <span class="cov8" title="1">{
        c.JSON(http.StatusBadRequest, model.CustomMessage{
                Message: err,
        })
}</span>
</pre>
		
		<pre class="file" id="file1" style="display: none">package api

import (
        "context"
        "employee-api/client"
        "employee-api/model"
        "github.com/gin-gonic/gin"
        "net/http"
)

var (
        ctx = context.Background()
)

// @Summary HealthCheckAPI is a method to perform healthcheck of application
// @Schemes http
// @Description Do healthcheck
// @Tags healthcheck
// @Accept json
// @Produce json
// @Success 200 {object} model.CustomMessage
// @Router /health [get]
// HealthCheckAPI is a method to perform healthcheck of application
func HealthCheckAPI(c *gin.Context) <span class="cov8" title="1">{
        scyllaClient, err := client.CreateScyllaDBClient()
        if err != nil </span><span class="cov8" title="1">{
                errorResponse(c, "Employee API is not running. Check application logs")
                return
        }</span>
        <span class="cov0" title="0">defer scyllaClient.Close()
        data := model.CustomMessage{
                Message: "Employee API is up and running",
        }
        c.JSON(http.StatusOK, data)</span>
}

// @Summary DetailedHealthCheckAPI is a method to perform detailed healthcheck of application
// @Schemes http
// @Description Do detailed healthcheck
// @Tags healthcheck
// @Accept json
// @Produce json
// @Success 200 {object} model.DetailedHealthCheck
// @Router /health/detail [get]
// DetailedHealthCheckAPI is a method to perform detailed healthcheck of application
func DetailedHealthCheckAPI(c *gin.Context) <span class="cov8" title="1">{
        scyllaClient, err := client.CreateScyllaDBClient()
        redisHealth := getRedisHealth()
        if err != nil </span><span class="cov8" title="1">{
                data := model.DetailedHealthCheck{
                        Message:     "Employee API is not running. Check application logs",
                        ScyllaDB:    "down",
                        EmployeeAPI: "down",
                        Redis:       redisHealth,
                }
                c.JSON(http.StatusBadRequest, data)
                return
        }</span>
        <span class="cov0" title="0">defer scyllaClient.Close()
        data := model.DetailedHealthCheck{
                Message:     "Employee API is up and running",
                ScyllaDB:    "up",
                EmployeeAPI: "up",
                Redis:       redisHealth,
        }
        c.JSON(http.StatusOK, data)</span>
}

// getRedisHealth is a method to get health of Redis
func getRedisHealth() string <span class="cov8" title="1">{
        redisClient := client.CreateRedisClient()
        err := redisClient.Ping(ctx).Err()
        if err != nil </span><span class="cov8" title="1">{
                return "down"
        }</span>
        <span class="cov0" title="0">return "up"</span>
}
</pre>
		
		<pre class="file" id="file2" style="display: none">package client

import (
        "employee-api/config"
        "github.com/redis/go-redis/v9"
)

// CreateRedisClient is a method for generating client of Redis
func CreateRedisClient() *redis.Client <span class="cov8" title="1">{
        config := config.ReadConfigAndProperty()
        return redis.NewClient(&amp;redis.Options{
                Addr:     config.Redis.Host,
                Password: config.Redis.Password,
                DB:       config.Redis.Database,
        })
}</span>
</pre>
		
		<pre class="file" id="file3" style="display: none">package client

import (
        "employee-api/config"
        "github.com/gocql/gocql"
        "github.com/sirupsen/logrus"
        "time"
)

// CreateScyllaDBClient is a method to create client connection for ScyllaDB
func CreateScyllaDBClient() (*gocql.Session, error) <span class="cov8" title="1">{
        config := config.ReadConfigAndProperty()
        client := gocql.NewCluster(config.ScyllaDB.Host...)
        fallback := gocql.RoundRobinHostPolicy()
        client.PoolConfig.HostSelectionPolicy = gocql.TokenAwareHostPolicy(fallback)
        client.Timeout = time.Duration(1) * time.Second
        client.Keyspace = config.ScyllaDB.Keyspace
        client.Authenticator = gocql.PasswordAuthenticator{
                Username: config.ScyllaDB.Username,
                Password: config.ScyllaDB.Password,
        }
        session, err := client.CreateSession()
        if err != nil </span><span class="cov8" title="1">{
                logrus.Errorf("Unable to create session with scylladb: %v", err)
        }</span>
        <span class="cov8" title="1">return session, err</span>
}
</pre>
		
		<pre class="file" id="file4" style="display: none">package config

import (
        "employee-api/model"
        "github.com/spf13/viper"
)

// ReadConfigAndProperty is a method for getting the configuration file details
func ReadConfigAndProperty() model.Config <span class="cov8" title="1">{
        var config model.Config
        viper.SetConfigName("config")
        viper.SetConfigType("yaml")
        viper.AddConfigPath("/etc/employee-api/")
        viper.AddConfigPath(".")
        err := viper.ReadInConfig()
        if err != nil </span><span class="cov8" title="1">{
                return config
        }</span>
        <span class="cov0" title="0">err = viper.Unmarshal(&amp;config)
        return config</span>
}
</pre>
		
		<pre class="file" id="file5" style="display: none">// Code generated by swaggo/swag. DO NOT EDIT.

package docs

import "github.com/swaggo/swag"

const docTemplate = `{
    "schemes": {{ marshal .Schemes }},
    "swagger": "2.0",
    "info": {
        "description": "{{escape .Description}}",
        "title": "{{.Title}}",
        "termsOfService": "http://swagger.io/terms/",
        "contact": {
            "name": "Opstree Solutions",
            "url": "https://opstree.com",
            "email": "opensource@opstree.com"
        },
        "license": {
            "name": "Apache 2.0",
            "url": "http://www.apache.org/licenses/LICENSE-2.0.html"
        },
        "version": "{{.Version}}"
    },
    "host": "{{.Host}}",
    "basePath": "{{.BasePath}}",
    "paths": {
        "/create": {
            "post": {
                "description": "Write data in database",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "employee"
                ],
                "summary": "CreateEmployeeData is a method to write employee information in database",
                "parameters": [
                    {
                        "description": "Employee Data",
                        "name": "employee",
                        "in": "body",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/model.Employee"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/model.Employee"
                        }
                    }
                }
            }
        },
        "/health": {
            "get": {
                "description": "Do healthcheck",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "healthcheck"
                ],
                "summary": "HealthCheckAPI is a method to perform healthcheck of application",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/model.CustomMessage"
                        }
                    }
                }
            }
        },
        "/health/detail": {
            "get": {
                "description": "Do detailed healthcheck",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "healthcheck"
                ],
                "summary": "DetailedHealthCheckAPI is a method to perform detailed healthcheck of application",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/model.DetailedHealthCheck"
                        }
                    }
                }
            }
        },
        "/search": {
            "get": {
                "description": "Read data from database",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "employee"
                ],
                "summary": "ReadEmployeeData is a method to read employee information",
                "parameters": [
                    {
                        "type": "string",
                        "description": "User ID",
                        "name": "id",
                        "in": "query",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/model.Employee"
                        }
                    }
                }
            }
        },
        "/search/all": {
            "get": {
                "description": "Read all employee data from database",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "employee"
                ],
                "summary": "ReadCompleteEmployeesData is a method to read all employee's information",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "type": "array",
                            "items": {
                                "$ref": "#/definitions/model.Employee"
                            }
                        }
                    }
                }
            }
        },
        "/search/designation": {
            "get": {
                "description": "Read all employee location data from database",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "employee"
                ],
                "summary": "ReadEmployeesDesignation is a method to read all employee designation",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/model.Designation"
                        }
                    }
                }
            }
        },
        "/search/location": {
            "get": {
                "description": "Read all employee location data from database",
                "consumes": [
                    "application/json"
                ],
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "employee"
                ],
                "summary": "ReadEmployeesLocation is a method to read all employee location",
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/model.Location"
                        }
                    }
                }
            }
        }
    },
    "definitions": {
        "model.CustomMessage": {
            "type": "object",
            "properties": {
                "message": {
                    "type": "string"
                }
            }
        },
        "model.Designation": {
            "type": "object",
            "properties": {
                "Consultant Partner": {
                    "type": "integer"
                },
                "DevOps Consultant": {
                    "type": "integer"
                },
                "DevOps Specialist": {
                    "type": "integer"
                },
                "Growth Partner": {
                    "type": "integer"
                }
            }
        },
        "model.DetailedHealthCheck": {
            "type": "object",
            "properties": {
                "employee_api": {
                    "type": "string"
                },
                "message": {
                    "type": "string"
                },
                "redis": {
                    "type": "string"
                },
                "scylla_db": {
                    "type": "string"
                }
            }
        },
        "model.Employee": {
            "type": "object",
            "properties": {
                "address": {
                    "type": "string"
                },
                "department": {
                    "type": "string"
                },
                "designation": {
                    "type": "string"
                },
                "email": {
                    "type": "string"
                },
                "id": {
                    "type": "string"
                },
                "joining_date": {
                    "type": "string"
                },
                "name": {
                    "type": "string"
                },
                "office_location": {
                    "type": "string"
                },
                "phone_number": {
                    "type": "string"
                },
                "status": {
                    "type": "string"
                }
            }
        },
        "model.Location": {
            "type": "object",
            "properties": {
                "Bangalore": {
                    "type": "integer"
                },
                "Delaware": {
                    "type": "integer"
                },
                "Hyderabad": {
                    "type": "integer"
                },
                "Noida": {
                    "type": "integer"
                }
            }
        }
    }
}`

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = &amp;swag.Spec{
        Version:          "1.0",
        Host:             "",
        BasePath:         "/api/v1",
        Schemes:          []string{"http"},
        Title:            "Employee API",
        Description:      "The REST API documentation for employee webserver",
        InfoInstanceName: "swagger",
        SwaggerTemplate:  docTemplate,
}

func init() <span class="cov0" title="0">{
        swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}</span>
</pre>
		
		<pre class="file" id="file6" style="display: none">package main

import (
        docs "employee-api/docs"
        "employee-api/middleware"
        "employee-api/routes"

        "github.com/gin-contrib/cors"
        "github.com/gin-gonic/gin"
        "github.com/penglongli/gin-metrics/ginmetrics"
        "github.com/sirupsen/logrus"
        swaggerfiles "github.com/swaggo/files"
        ginSwagger "github.com/swaggo/gin-swagger"
)

var router = gin.New()

func init() <span class="cov0" title="0">{
        logrus.SetLevel(logrus.InfoLevel)
        logrus.SetFormatter(&amp;logrus.JSONFormatter{}) // NEW
}</span>

// @title Employee API
// @version 1.0
// @description The REST API documentation for employee webserver
// @termsOfService http://swagger.io/terms/

// @contact.name Opstree Solutions
// @contact.url https://opstree.com
// @contact.email opensource@opstree.com

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html
// @BasePath /api/v1
// @schemes http
func main() <span class="cov0" title="0">{
        monitor := ginmetrics.GetMonitor()
        monitor.SetMetricPath("/metrics")
        monitor.SetSlowTime(1)
        monitor.SetDuration([]float64{0.1, 0.3, 1.2, 5, 10})
        monitor.Use(router)

        // Global middlewares
        router.Use(gin.Recovery())
        router.Use(middleware.LoggingMiddleware())

        // CORS Middleware
        router.Use(cors.New(cors.Config{
                AllowOrigins: []string{"http://downtimecrew.xyz:3000", "http://54.165.93.34:3000", "https://www.downtimecrew.xyz:3000"}, // Replace with your frontend domain if deployed
                AllowMethods:     []string{"GET", "POST", "PUT", "DELETE"},
                AllowHeaders:     []string{"Origin", "Content-Type", "Accept"},
                ExposeHeaders:    []string{"Content-Length"},
                AllowCredentials: true,
        }))

        // API routes
        v1 := router.Group("/api/v1")
        docs.SwaggerInfo.BasePath = "/api/v1/employee"
        routes.CreateRouterForEmployee(v1)

        // Swagger UI
        url := ginSwagger.URL("http://54.165.93.34:8081/swagger/doc.json")
        router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler, url))

        // Start server
        router.Run(":8081")
}</span>
</pre>
		
		<pre class="file" id="file7" style="display: none">package middleware

import (
        "time"

        "github.com/gin-gonic/gin"
        log "github.com/sirupsen/logrus"
)

// LoggingMiddleware is a method to set formatter of logrus
func LoggingMiddleware() gin.HandlerFunc <span class="cov8" title="1">{
        return func(ctx *gin.Context) </span><span class="cov8" title="1">{
                // Starting time request
                startTime := time.Now()

                // Processing request
                ctx.Next()

                // End Time request
                endTime := time.Now()

                // execution time
                latencyTime := endTime.Sub(startTime)

                // Request method
                reqMethod := ctx.Request.Method

                // Request route
                reqUri := ctx.Request.RequestURI

                // status code
                statusCode := ctx.Writer.Status()

                // Request IP
                clientIP := ctx.ClientIP()

                log.WithFields(log.Fields{
                        "http_method": reqMethod,
                        "request_uri": reqUri,
                        "status_code": statusCode,
                        "latency":     latencyTime,
                        "client_ip":   clientIP,
                }).Info("HTTP REQUEST STATUS")

                ctx.Next()
        }</span>
}
</pre>
		
		<pre class="file" id="file8" style="display: none">package routes

import (
        "employee-api/api"
        "github.com/gin-gonic/gin"
)

// @BasePath /employee
// CreateRouterForEmployee is a method for generate routes
func CreateRouterForEmployee(routerGroup *gin.RouterGroup) <span class="cov8" title="1">{
        employee := routerGroup.Group("/employee")
        employee.GET("/health", api.HealthCheckAPI)
        employee.GET("/health/detail", api.DetailedHealthCheckAPI)
        employee.POST("/create", api.CreateEmployeeData)
        employee.GET("/search", api.ReadEmployeeData)
        employee.GET("/search/all", api.ReadCompleteEmployeesData)
        employee.GET("/search/location", api.ReadEmployeesLocation)
        employee.GET("/search/designation", api.ReadEmployeesDesignation)
}</span>
</pre>
		
		</div>
	</body>
	<script>
	(function() {
		var files = document.getElementById('files');
		var visible;
		files.addEventListener('change', onChange, false);
		function select(part) {
			if (visible)
				visible.style.display = 'none';
			visible = document.getElementById(part);
			if (!visible)
				return;
			files.value = part;
			visible.style.display = 'block';
			location.hash = part;
		}
		function onChange() {
			select(files.value);
			window.scrollTo(0, 0);
		}
		if (location.hash != "") {
			select(location.hash.substr(1));
		}
		if (!visible) {
			select("file0");
		}
	})();
	</script>
</html>
