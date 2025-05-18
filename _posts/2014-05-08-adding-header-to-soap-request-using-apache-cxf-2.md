---
id: 256
title: 'SOAP Webservices Using Apache CXF : Adding Custom Object as Header in Outgoing Requests'
date: '2014-05-08T21:26:21-07:00'
author: saurzcode

guid: 'https://saurzcode.in//?p=256'
permalink: /2014/05/adding-header-to-soap-request-using-apache-cxf-2/
geo_public:
    - '0'
publicize_linkedin_url:
    - 'http://www.linkedin.com/updates?discuss=&scope=23596248&stype=M&topic=5870199325182697472&type=U&a=u6YW'
dsq_thread_id:
    - '3280625893'
meta-checkbox:
    - ''
categories:
    - Java
    - Technology
tags:
    - apache
    - cxf
    - java
    - soap
    - webservice
---

## What is Apache CXF?

Apache CXF is an open source services framework. CXF helps you build and develop services using frontend programming APIs, like JAX-WS and JAX-RS. These services can speak a variety of protocols such as SOAP, XML/HTTP, RESTful HTTP, or CORBA and work over a variety of transports such as HTTP, JMS etc.
<!--more-->
## How CXF Works?

Most of the functionality in the Apache CXF runtime is implemented by interceptors. Every endpoint created by the Apache CXF runtime has potential interceptor chains for processing messages. The interceptors in these chains are responsible for transforming messages between the raw data transported across the wire and the Java objects handled by the endpoint's implementation code.

## Interceptors in CXF

When a CXF client invokes a CXF server, there is an outgoing interceptor chain for the client and an incoming chain for the server. When the server sends the response back to the client, there is an outgoing chain for the server and an incoming one for the client. Additionally, in the case of SOAPFaults, a CXF web service will create a separate outbound error handling chain and the client will create an inbound error handling chain.

The interceptors are organized into phases to ensure that processing happens in the proper order. Various phases involved during the Interceptor chains are listed in CXF documentation [here](https://cxf.apache.org/docs/interceptors.html).

Adding your custom Interceptor involves extending one of the Abstract Interceptor classes that CXF provides, and providing a phase when that interceptor should be invoked.

**AbstractPhaseInterceptor** class - This abstract class provides implementations for the phase management methods of the PhaseInterceptor interface. The **AbstractPhaseInterceptor** class also provides a default implementation of the **handleFault()** method.

Developers need to provide an implementation of the **handleMessage()** method. They can also provide a different implementation for the **handleFault()** method. The developer-provided implementations can manipulate the message data using the methods provided by the generic **org.apache.cxf.message.Message** interface.

For applications that work with SOAP messages, Apache CXF provides an **AbstractSoapInterceptor** class. Extending this class provides the **handleMessage()** method and the **handleFault()** method with access to the message data as an **org.apache.cxf.binding.soap.SoapMessage** object. **SoapMessage** objects have methods for retrieving the SOAP headers, the SOAP envelope, and other SOAP metadata from the message.

Below piece of code will show, how we can add a Custom Object as Header to an outgoing request –

**Spring Configuration**

```xml
<jaxws:client id="mywebServiceClient"
serviceClass="com.saurzcode.TestService"
address="https://saurzcode.in/:8088/mockTestService">

<jaxws:binding>
<soap:soapBinding version="1.2" mtomEnabled="true" />
</jaxws:binding>
</jaxws:client>
<cxf:bus>
<cxf:outInterceptors>
<bean class="com.saurzcode.ws.caller.SoapHeaderInterceptor" />
</cxf:outInterceptors>
</cxf:bus>
```

**Interceptor**

```java
public class SoapHeaderInterceptor extends AbstractSoapInterceptor {

public SoapHeaderInterceptor() {

super(Phase.POST_LOGICAL);

}

@Override
public void handleMessage(SoapMessage message) throws Fault {

List<Header> headers = message.getHeaders();

TestHeader testHeader = new TestHeader();

JAXBElement<TestHeader> testHeaders = new ObjectFactory()

.createTestHeader(testHeader);

try {

Header header = new Header(testHeaders.getName(), testHeader,

new JAXBDataBinding(TestHeader.class));

headers.add(header);

message.put(Header.HEADER_LIST, headers);

} catch (JAXBException e) {

e.printStackTrace();

}

}
}
```

---

## You may also like:

- [Recommended readings for Hadoop](https://saurzcode.in//2014/02/04/recommended-readings-for-hadoop/)
- [Free Online Hadoop Trainings](https://saurzcode.in//2014/04/21/free-online-hadoop-trainings/)
- [How to become a Hadoop Certified Developer ?](https://saurzcode.in//2014/05/31/everything-about-hadoop-certifications/)