
# LiveDocs

## What is LiveDocs?
This tool is the result of my master thesis "LiveDocs: Document-Centric Process Management".

LiveDocs allows the development of form-driven web applications using CINCO. It consist of two components, a modeling tool and a web
application. With the modeling tool, a LiveDocs-modeler can create different document types. The modeler defines the content of document, such as panels and input fields. Furthermore, the structure of a document can be modeled by using the defined panels. The document’s structure does not follow a rigid process, and thus “living” documents can be created. Therefore, only dependencies between the form parts are controlled automatically. The corresponding web application includes the defined document types so that a LiveDocs-user can create a document of a specific type and can fill in the included form. In the web
application, a user can complete a document by filling out and submitting a form. The document is validated automatically to guarantee semantic correctness. In addition to semantic correctness, the document is model checked by satisfying global constraints.

![overview_codegeneration](https://user-images.githubusercontent.com/80321708/111160932-e0ecb880-859a-11eb-8ae5-e9f630b4109d.png)

## How to use it

1. Download a CINCO Installer from [here](https://cinco.scce.info/download/). Open the installer and make sure to use Java 1.8.
2. Import the projects 'info.scce.cinco.product.docuemntproject' and 'info.scce.cinco.product.docuemntproject.views'
3. Go to 'info.scce.cinco.product.docuemntproject' -> model -> DocumentProjectTool.cpd. Right-klick on it and choose "Generate Cinco product".
4. After generation, start a new instance.
5. In this new instance you can create a "New Document Project", where you can use the 4 DSLs to create your web application.
 Concept of these DSLs:  
![conceptDSLs2](https://user-images.githubusercontent.com/80321708/111160747-aedb5680-859a-11eb-87b8-7f9aff1c82f4.png)


6. After modeling, you can generat the correspondind web application by hittin the "G"-Button in the upper toolbar.
7. To start the web application you have to do the following steps:
    1. Build m3c: `cd m3c`and then `mvn install`
    2. Build livedocs-ws: `cd livedocs-ws`and then `mvn install`
    3. start the server: `cd livedocs-ws` and then `java -jar target/livedocs-ws-1.0-SNAPSHOT-jar-with-dependencies.jar'
    4. Go to "pubsepc.yaml" and run `pub get` and `pub update'
    5. Run application: 'pub global run webdev serve web:53322". (You can also choose "run index.html" in the context menu of 'index.html'.


## LiveDocs Web Application

In the web app, you can login with the credenitals username: <role name> and password: <role name>. if you created a role "admin" your credentials are username: admin and passwort admin. With the web app, you can create a new document of your defined document type. The document includes different form parts, which are added dynamically based on your input. After each panel submission, the document status is checked (semantic validation via DTD). Here are some pictures of the generated web application:
 
![overview](https://user-images.githubusercontent.com/80321708/111161682-b4856c00-859b-11eb-9a7c-3729646ddbef.png)
 ![userspage](https://user-images.githubusercontent.com/80321708/111161770-c7983c00-859b-11eb-9ecf-5d4494aee2f8.png)
![openDoc](https://user-images.githubusercontent.com/80321708/111161790-cc5cf000-859b-11eb-9f63-a2f879fb8e8a.png)
