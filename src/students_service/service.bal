import ballerina/http;
import ballerina/jsonutils;
import ballerina/io;
import ballerina/lang.'int as ints;
import manage_students;

http:Client clientEP = new("http://localhost:9090");

@http:ServiceConfig {
    basePath: "/student",
    cors: {
        allowOrigins: ["*"]
    }
}

service studentService on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/getAllStudents"
    }
    resource function getAllStudents(http:Caller caller, http:Request req) {

        table<record {}>|error allStudents = manage_students:getAllStudents();
        http:Response response = new;

        if (allStudents is table<record {}>) {
            json retValJson = jsonutils:fromTable(allStudents);
            io:println("JSON: ", retValJson.toJsonString());

            response.setTextPayload(retValJson.toJsonString());
            response.statusCode = http:STATUS_OK;
        } else {
            response.setPayload("Error in constructing a json from student!");
            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/getStudent/{studentId}"
    }
    resource function getStudent(http:Caller caller, http:Request req, int studentId) {

        manage_students:Student|error student = manage_students:getStudent(studentId);
        http:Response response = new;

        if (student is manage_students:Student) {
            json|error retValJson = json.constructFrom(student);

            if (retValJson is json) {
                io:println("JSON: ", retValJson.toJsonString()); 
                response.setTextPayload(<@untained>  retValJson.toJsonString()); 
                response.statusCode = http:STATUS_OK; 
            } else {
                response.setPayload("Error in constructing a json from student!");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            }
        } else {
            response.setPayload("Error in constructing a json from student!");
            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
        }

        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/insertStudent"
    }
    resource function insertStudent(http:Caller caller, http:Request
                                        request) {
        
        http:Response response = new;
        
        // Replace the jsonPayload with the below commented if the request is from forms.

        // var data = request.getFormParams();
        // if (data is map<string>) {

        //     int|error studentId = ints:fromString(data.get("studentId"));
        //     string fullName = data.get("fullName");
        //     int|error age = ints:fromString(data.get("age"));
        //     string address = data.get("address");   
        // }    

        var jsonPayload = request.getJsonPayload();

        if (jsonPayload is json) {

            int|error studentId = ints:fromString(jsonPayload.student.id.toString());
            string fullName = jsonPayload.student.fullName.toString();
            int|error age = ints:fromString(jsonPayload.student.age.toString());
            string address = jsonPayload.student.address.toString();

            boolean|error insertionStatus;

            if (studentId is int && age is int) {
                insertionStatus = manage_students:insertStudent(studentId, fullName, age, address);

                if (insertionStatus is boolean && insertionStatus == true) {
                    response.setPayload("Student inserted successfully!");
                    response.statusCode = http:STATUS_OK;
                } else {
                    response.setPayload("Student insertion failed!");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                }
            } else {
                response.setPayload("Invalid inputs!");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            }
            
        } else {
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload("Invalid payload received");
        }
        
        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/updateStudent"
    }
    resource function updateStudent(http:Caller caller, http:Request
                                        request) {
                                            
        http:Response response = new;

        // Replace the jsonPayload with the below commented if the request is from forms.

        // var data = request.getFormParams();
        // if (data is map<string>) {

        //     int|error studentId = ints:fromString(data.get("studentId"));
        //     string fullName = data.get("fullName");
        //     int|error age = ints:fromString(data.get("age"));
        //     string address = data.get("address");   
        // }

        var jsonPayload = request.getJsonPayload();

        if (jsonPayload is json) {

            int|error studentId = ints:fromString(jsonPayload.student.id.toString());
            string fullName = jsonPayload.student.fullName.toString();
            int|error age = ints:fromString(jsonPayload.student.age.toString());
            string address = jsonPayload.student.address.toString();

            boolean|error updationStatus;

            if (studentId is int && age is int) {
                updationStatus = manage_students:updateStudent(studentId, fullName, age, address);

                if (updationStatus is boolean && updationStatus == true) {
                    response.setPayload("Student updated successfully!");
                    response.statusCode = http:STATUS_OK;
                } else {
                    response.setPayload("Student updation failed!");
                    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                }
            } else {
                response.setPayload("Invalid inputs!");
                response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            }
            
        } else {
            response.statusCode = http:STATUS_NOT_ACCEPTABLE;
            response.setPayload("Invalid payload received");
        }
        
        error? respond = caller->respond(response);
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/deleteStudent/{studentId}"
    }
    resource function deleteStudent(http:Caller caller, http:Request req, int studentId) {

        boolean|error status = manage_students:deleteStudent(studentId);
        http:Response response = new;

        if (status is boolean && status == true) {
            response.setPayload("Student deleted successfully!");
            response.statusCode = http:STATUS_OK;
        } else {
            response.setPayload("Could not delete the specified student!");
            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
        }

        error? respond = caller->respond(response);
    }
}
