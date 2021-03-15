package info.scce.cinco.product.documentproject.generator.DTD

import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import graphmodel.Node
import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.dependency.dependency.AND
import info.scce.cinco.product.documentproject.dependency.dependency.OR
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import java.util.List
import java.util.ArrayList
import java.util.stream.Collectors

class WebService_Generator {
	static extension Helper = new Helper()
	
	def generate(Documents docs)'''
	package de.livedocs;
	
	import java.io.IOException;
	import java.io.OutputStream;
	import java.net.InetSocketAddress;
	import java.io.InputStream;
	import java.io.ByteArrayInputStream;
	import java.io.InputStreamReader;
	import java.io.BufferedReader;
	import java.util.stream.Collectors;
	
	import com.sun.net.httpserver.HttpExchange;
	import com.sun.net.httpserver.HttpHandler;
	import com.sun.net.httpserver.HttpServer;
	import com.google.gson.Gson;
	import com.google.gson.JsonElement;
	import com.google.gson.JsonObject;
	import com.google.gson.JsonParser;
	import com.sun.net.httpserver.Headers;
	
	// DOM
	import javax.xml.parsers.DocumentBuilder;
	import javax.xml.parsers.DocumentBuilderFactory;
	// SAX
	import javax.xml.parsers.SAXParser;
	import javax.xml.parsers.SAXParserFactory;
	import org.xml.sax.XMLReader;
	
	import info.scce.m3c.cfps.CFPS;
	import info.scce.m3c.solver.SolveBDD;
	import info.scce.m3c.solver.SolveDD;
	import info.scce.m3c.util.XMLDeserializer;
	
	import javax.xml.parsers.ParserConfigurationException;
	
	import org.xml.sax.ErrorHandler;
	import org.xml.sax.SAXException;
	import org.xml.sax.SAXParseException;
	import org.xml.sax.InputSource;

	
	public class WebService {
	
		public static void main(String[] args) throws Exception {
			HttpServer server = HttpServer.create(new InetSocketAddress(8000), 0);
			server.createContext("/xmlvalidation", new MyHandler());
			server.createContext("/modelchecking", new MCHandler());
			server.setExecutor(null); // creates a default executor
			System.out.println("start webservice on port 8000");
			server.start();
		}
		
		static class MCHandler implements HttpHandler {
					@Override
					public void handle(HttpExchange t) throws IOException {
		                System.out.println("MCHandler");
						String requestMethod = t.getRequestMethod();
						System.out.println(requestMethod + " /post");
						if (requestMethod.equalsIgnoreCase("OPTIONS")) {
		                            Headers responseHeaders = t.getResponseHeaders();
		                            responseHeaders.add("Access-Control-Allow-Origin", "*");
		                            responseHeaders.add("Access-Control-Allow-Credentials", "true");
		                            responseHeaders.add("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT");
		                            responseHeaders.add("Access-Control-Allow-Headers", "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers");
		                            responseHeaders.add("Content-Type", "application/json");
		                            String response = "Options response";
		                            t.sendResponseHeaders(200, response.length());
		                            OutputStream os = t.getResponseBody();
		                            os.write(response.getBytes());
		                            os.close();
		                            return;
						}
		
						    System.out.println(requestMethod + " /post");
		                    if (requestMethod.equalsIgnoreCase("POST")) {
		                    	String body = new BufferedReader(new InputStreamReader(t.getRequestBody())).lines().collect(Collectors.joining("\n"));
		                    	System.out.println(body);
		                    
		                    
		                    	try {
		                    		String result = modelChecking(body);
		                    	    System.out.println("result:" + result);
		                    	    String response = result;
		                    	    Headers responseHeaders = t.getResponseHeaders();
		                    	    responseHeaders.add("Access-Control-Allow-Origin", "*");
		                    	    responseHeaders.add("Content-Type", "application/json");
		                    	    t.sendResponseHeaders(200, response.length());
		                    	    OutputStream os = t.getResponseBody();
		                    	    os.write(response.getBytes());
		                    	    os.close();
		                    	 } catch (Exception e) {
		                    	 	e.printStackTrace();
		                    	    String response = "Model Checking failed., " + e.getMessage();
		                    	    Headers responseHeaders = t.getResponseHeaders();
		                    	    responseHeaders.add("Access-Control-Allow-Origin", "*");
		                    	    t.sendResponseHeaders(400, response.length());
		                    	    OutputStream os = t.getResponseBody();
		                    	    os.write(response.getBytes());
		                    	    os.close();
		                    	 }
		                    }
		                }
		
				}
		
		
		public static String modelChecking(String body){
				try{
			    	JsonElement parsedJson =  JsonParser.parseString(body);
			        System.out.println(parsedJson);
			        JsonObject json = parsedJson.getAsJsonObject();
			        String cfpsXML = json.get("CFPS").getAsString();
			        System.out.println(cfpsXML);
			        String ctlFormula = json.get("CTLFormula").getAsString();
			        System.out.println(ctlFormula);
			        XMLDeserializer deserializer = new XMLDeserializer(cfpsXML);
			        CFPS cfps = deserializer.deserialize();
			        SolveDD solver = new SolveBDD(cfps, ctlFormula, true);
			        solver.solve();
			        boolean isSat = solver.isSat();
			        System.out.println(isSat);
			        if(isSat){
			            return "{\"isSat\":true,\"message\":\"All constraints are satisfied.\"}";
			        }else{
			             return "{\"isSat\":false,\"message\":\"Constraints are not satisfied.\"}";
			        }
			       }
				   catch(Exception e){
				    return "{\"isSat\":false,\"message\":\"" + e.getMessage() + "\"}";
				}
			}
	
		static class MyHandler implements HttpHandler {
			@Override
			public void handle(HttpExchange t) throws IOException {
	
				String requestMethod = t.getRequestMethod();
				System.out.println(requestMethod + " /post");
				if (requestMethod.equalsIgnoreCase("POST")) {
					String body = new BufferedReader(new InputStreamReader(t.getRequestBody())).lines()
							.collect(Collectors.joining("\n"));
					// System.out.println(body);
	
					/*
					 * {"valid": true, message: ''}
					 */
	
					try {
						String result = validateWithDTDUsingDOM(body);
						System.out.println("result:" + result);
						String response = result;
						Headers responseHeaders = t.getResponseHeaders();
						responseHeaders.add("Access-Control-Allow-Origin", "*");
						responseHeaders.add("Content-Type", "application/json");
						t.sendResponseHeaders(200, response.length());
						OutputStream os = t.getResponseBody();
						os.write(response.getBytes());
						os.close();
					} catch (Exception e) {
						e.printStackTrace();
						String response = "Validation failed, " + e.getMessage();
						Headers responseHeaders = t.getResponseHeaders();
						responseHeaders.add("Access-Control-Allow-Origin", "*");
						t.sendResponseHeaders(400, response.length());
						OutputStream os = t.getResponseBody();
						os.write(response.getBytes());
						os.close();
					}
				}
	
			}
	
			public static String validateWithDTDUsingDOM(String xml) throws ParserConfigurationException, IOException {
				try {
					DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
					factory.setValidating(true);
					factory.setNamespaceAware(true);
	
					DocumentBuilder builder = factory.newDocumentBuilder();
					builder.setErrorHandler(new ErrorHandler() {
						public void warning(SAXParseException e) throws SAXException {
							System.out.println("WARNING : " + e.getMessage()); // do nothing
						}
	
						public void error(SAXParseException e) throws SAXException {
							System.out.println("ERROR : " + e.getMessage());
							throw e;
	
						}
	
						public void fatalError(SAXParseException e) throws SAXException {
							System.out.println("FATAL : " + e.getMessage());
							throw e;
						}
					});
	
					InputStream targetStream = new ByteArrayInputStream(xml.getBytes());
	
					builder.parse(targetStream);
					return "{\"valid\":true,\"message\":\"VALID.\"}";
				} catch (ParserConfigurationException | SAXException e) {
					e.printStackTrace();
					String msg = e.getMessage().replace("\"", "''").replace("(", "").replace(")", "");
					return "{\"valid\":false,\"message\":\"INVALID: " + replaceTagNames(msg) + "\"}";
				}
			}
			
			
			private static String replaceTagNames(String msg) {
				String newMsg = msg«replaces(docs)»
				return newMsg;
			}
		}
	
	}
	'''
	
	def replaces(Documents docs)'''«FOR panel : docs.elements BEFORE "." SEPARATOR "." AFTER";"»replaceAll("«panel.tags»","«panel.name»")«ENDFOR»'''
	
	def name(Node node){
		switch(node){
			AND: '''AND'''
			XOR:'''Please choose one'''
			OR:'''OR'''
			Panel : '''«(node as Panel).tmplPanel.name»'''
		}
	}
	
	def getTags(Node node){
		switch(node){
			AND: '''and«(node as AND).id.toLowerCase.replace("_","-")»'''
			XOR:'''xor-«(node as XOR).id.toLowerCase.replace("_","-")»'''
			OR:'''or«(node as OR).id.toLowerCase.replace("_","-")»'''
			Panel : '''«(node as Panel).escape.toLowerCase.replace("_","-")»'''
		}
	}
	
	def List<Node> elements(Documents docs) {
		var allElements = new ArrayList<Node>();
		for(doc : docs.documents){
			var dep = doc.dependency as Dependency
			allElements.addAll(dep.ANDs)
			allElements.addAll(dep.ORs)
			allElements.addAll(dep.XORs)
			allElements.addAll(dep.allPanels)
			
		}
		
		var elements = allElements.stream().distinct().collect(Collectors.toList());
		return elements
	}
}