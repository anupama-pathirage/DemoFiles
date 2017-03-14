import ballerina.lang.datatables;
import ballerina.data.sql;
import ballerina.lang.messages;
import ballerina.lang.jsons;

@http:BasePath("/employees")
service Employee {
	map propertiesMap = {"jdbcUrl":"jdbc:oracle:thin:@localhost:1521/xe", "username":"system", "password":"oracle"};
	sql:ClientConnector empDBConnector = create sql:ClientConnector(propertiesMap);
	
	@http:GET
	@http:Path("/")
	resource getAllEmployees(message m) {
		sql:Parameter[] params = [];
		datatable dt = sql:ClientConnector.select(empDBConnector, "select * from employees", params);
		xml payload = datatables:toXml(dt, "results", "result");
		message response = {};
		messages:setXmlPayload(response, payload);
		reply response;		
	}
	
	@http:GET
	@http:Path("/{employeeID}")
	resource getEmployee(message m, 
	@http:PathParam("employeeID")string employeeID) {
		sql:Parameter para1 = {sqlType:"integer", value:employeeID, direction:0};		
		string query = "select * from employees where emp_no=?";
		sql:Parameter[] params = [para1];
		datatable dt = sql:ClientConnector.select(empDBConnector, query, params);
		json payload = datatables:toJson(dt);
		message response = {};
		messages:setJsonPayload(response, payload);
		reply response;		
	}
	
	@http:POST
	@http:Path("/")
	resource insertEmployee(message m) {
		json requestPayload = messages:getJsonPayload(m);
		string birthdate = jsons:getString(requestPayload, "$.birth_date");
		string firstName = jsons:getString(requestPayload, "$.first_name");
		string lastName = jsons:getString(requestPayload, "$.last_name");
		string gender = jsons:getString(requestPayload, "$.gender");
		string hiredate = jsons:getString(requestPayload, "$.hire_date");
		sql:Parameter para2 = {sqlType:"varchar", value:birthdate, direction:0};
		sql:Parameter para3 = {sqlType:"varchar", value:firstName, direction:0};
		sql:Parameter para4 = {sqlType:"varchar", value:lastName, direction:0};
		sql:Parameter para5 = {sqlType:"varchar", value:gender, direction:0};
		//sql:Parameter para6 = {sqlType:"varchar", value:hiredate, direction:0};
		sql:Parameter[] params = [para2, para3, para4, para5];
		string query = "Insert into employees(birth_date,first_name,last_name,gender) values (?,?,?,?)";
		sql:ClientConnector.update(empDBConnector, query, params);
		message response = {};
		string payload = "Data Insertion Successfull ";
		messages:setStringPayload(response, payload);
		reply response;		
	}
	
	@http:PUT
	@http:Path("/{employeeID}")
	resource updateEmployee(message m, 
	@http:PathParam("employeeID")string employeeID) {
		json requestPayload = messages:getJsonPayload(m);
		string firstName = jsons:getString(requestPayload, "$.first_name");
		string lastName = jsons:getString(requestPayload, "$.last_name");
		sql:Parameter para1 = {sqlType:"varchar", value:firstName, direction:0};
		sql:Parameter para2 = {sqlType:"varchar", value:lastName, direction:0};
		sql:Parameter para3 = {sqlType:"integer", value:employeeID, direction:0};
		sql:Parameter[] params = [para1, para2, para3];
		string query = "update employees set first_name = ?, last_name = ? where emp_no=?";
		int updateCount = sql:ClientConnector.update(empDBConnector, query, params);
		string countStr = updateCount + " record(s) updated.\n";
		message response = {};
		messages:setStringPayload(response, countStr);
		reply response;		
	}
	
	@http:DELETE
	@http:Path("/{employeeID}")
	resource deleteEmployee(message m, 
	@http:PathParam("employeeID")string employeeID) {
		sql:Parameter para1 = {sqlType:"integer", value:employeeID, direction:0};
		sql:Parameter[] params = [para1];
		string query = "delete from employees where emp_no=?";
		int updateCount = sql:ClientConnector.update(empDBConnector, query, params);
		string countStr = updateCount + " record(s) deleted.\n";
		message response = {};
		messages:setStringPayload(response, countStr);
		reply response;		
	}	
}
