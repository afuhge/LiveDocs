# LiveDocs

## What is LiveDocs?
This tool is the result of my master thesis "LiveDocs: Document-Centric Process Management".

LiveDocs allows the development of form-driven web applications using CINCO. It consist of two components, a modeling tool and a web
application. With the modeling tool, a LiveDocs-modeler can create different document types. The modeler defines the content of document, such as panels and input fields. Furthermore, the structure of a document can be modeled by using the defined panels. The document’s structure does not follow a rigid process, and thus “living” documents can be created. Therefore, only dependencies between the form parts are controlled automatically. The corresponding web application includes the defined document types so that a LiveDocs-user can create a document of a specific type and can fill in the included form. In the web
application, a user can complete a document by filling out and submitting a form. The document is validated automatically to guarantee semantic correctness. In addition to semantic correctness, the document is model checked by satisfying global constraints.

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
    1. start the server:
    2. Go to "pubsepc.yaml" and run 'pub get' and 'pub update'
    3. Run application: 'pub global run webdev serve web:53322". (You can also choose "run index.html" in the context menu of 'index.html'.
