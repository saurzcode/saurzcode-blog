---
id: 256
title: 'SOAP Webservices Using Apache CXF : Adding Custom Object as Header in Outgoing Requests'
date: '2014-05-08T21:26:21-07:00'
author: saurzcode
layout: post
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

<h2 style="color: #222222;"><b>What is Apache CXF?</b></h2>
<p style="color: #222222;">Apache CXF is an open source services framework. CXF helps you build and develop services using frontend programming APIs, like JAX-WS and JAX-RS. These services can speak a variety of protocols such as SOAP, XML/HTTP, RESTful HTTP, or CORBA and work over a variety of transports such as HTTP, JMS etc.</p>

<h2 style="color: #222222;"><b>How CXF Works?</b></h2>
<p style="color: #222222;">As you can see  <a class="vt-p" style="color: #20328e;" href="http://java.dzone.com/articles/apache-cxf-how-message">here</a>,  as how CXF service calls are processed,most of the functionality in the Apache CXF runtime is implemented by interceptors. Every endpoint created by the Apache CXF runtime has potential interceptor chains for processing messages. The interceptors in the these chains are responsible for transforming messages between the raw data transported across the wire and the Java objects handled by the endpoint’s implementation code.</p>

<h2 style="color: #222222;"><b>Interceptors in CXF</b></h2>
<p style="color: #222222;">When a CXF client invokes a CXF server, there is an outgoing interceptor chain for the client and an incoming chain for the server. When the server sends the response back to the client, there is an outgoing chain for the server and an incoming one for the client. Additionally, in the case of SOAPFaults, a CXF web service will create a separate outbound error handling chain and the client will create an inbound error handling chain.</p>
<p style="color: #222222;">The interceptors are organized into phases to ensure that processing happens on the proper order.Various phases involved during the Interceptor chains are listed in CXF documentation <a class="vt-p" style="color: #20328e;" href="https://cxf.apache.org/docs/interceptors.html">here.</a></p>
<p style="color: #222222;">Adding your custom Interceptor involves extending one of the Abstract Intereceptor classes that CXF provides, and providing a phase when that interceptor should be invoked.</p>
<p style="color: #222222;"><b><i>AbstractPhaseInterceptor</i> </b>class - This abstract class provides implementations for the phase management methods of the PhaseInterceptor interface. The <i>AbstractPhaseInterceptor </i>class also provides a default implementation of the <i>handleFault() </i>method.</p>
<p style="color: #222222;">Developers need to provide an implementation of the <i>handleMessage()</i> method. They can also provide a different implementation for the <i>handleFault()</i> method. The developer-provided implementations can manipulate the message data using the methods provided by the generic <i>org.apache.cxf.message.Message</i> interface.</p>
<p style="color: #222222;">For applications that work with SOAP messages, Apache CXF provides an <i>AbstractSoapInterceptor</i> class. Extending this class provides the <i>handleMessage()</i> method and the <i>handleFault()</i> method with access to the message data as an <i>org.apache.cxf.binding.soap.SoapMessage </i>object.<i> SoapMessage</i> objects have methods for retrieving the SOAP headers, the SOAP envelope, and other SOAP metadata from the message.</p>
<p style="color: #222222;">Below piece of code will show, how we can add a Custom Object as Header to an outgoing request –</p>
<p style="color: #222222;"><strong>Spring Configuration</strong></p>

<pre class="lang:xhtml decode:true ">&lt;jaxws:client id="mywebServiceClient"
serviceClass="com.saurzcode.TestService"
address="https://saurzcode.in/:8088/mockTestService"&gt;

&lt;jaxws:binding&gt;
&lt;soap:soapBinding version="1.2" mtomEnabled="true" /&gt;
&lt;/jaxws:binding&gt;
&lt;/jaxws:client&gt;
&lt;cxf:bus&gt;
&lt;cxf:outInterceptors&gt;
&lt;bean class="com.saurzcode.ws.caller.SoapHeaderInterceptor" /&gt;
&lt;/cxf:outInterceptors&gt;
&lt;/cxf:bus&gt;</pre>
<strong>Interceptor</strong> :-
<pre class="lang:java decode:true ">public class SoapHeaderInterceptor extends AbstractSoapInterceptor {

public SoapHeaderInterceptor() {

super(Phase.POST_LOGICAL);

}

@Override
public void handleMessage(SoapMessage message) throws Fault {

List&lt;Header&gt; headers = message.getHeaders();

TestHeader testHeader = new TestHeader();

JAXBElement&lt;TestHeader&gt; testHeaders = new ObjectFactory()

.createTestHeader(testHeader);

try {

Header header = new Header(testHeaders.getName(), testHeader,

new JAXBDataBinding(TestHeader.class));

headers.add(header);

message.put(Header.HEADER_LIST, headers);

} catch (JAXBException e) {

e.printStackTrace();

}

}</pre>
&nbsp;

<hr />

<h4>You may also like :</h4>
<ul>
	<li><span style="text-decoration: underline;"><em><a class="vt-p" title="Recommended Readings for Hadoop" href="https://saurzcode.in//2014/02/04/recommended-readings-for-hadoop/">Recommended readings for Hadoop</a></em></span></li>
	<li><span style="text-decoration: underline;"><em><a class="vt-p" title="Free Online Hadoop Trainings" href="https://saurzcode.in//2014/04/21/free-online-hadoop-trainings/">Free Online Hadoop Trainings</a></em></span></li>
	<li><span style="text-decoration: underline;"><em><a class="vt-p" title="How to Become a Hadoop Certified Developer ?" href="https://saurzcode.in//2014/05/31/everything-about-hadoop-certifications/">How to become a Hadoop Certified Developer ?</a></em></span></li>
</ul>