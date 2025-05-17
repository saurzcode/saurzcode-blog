---
id: 913
title: 'How-To : Write a Kafka Producer using Twitter Stream ( Twitter HBC Client)'
date: '2015-02-12T00:47:49-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in//?p=913'
permalink: /2015/02/kafka-producer-using-twitter-stream/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3508545894'
classic-editor-remember:
    - classic-editor
categories:
    - 'Big Data'
    - Java
    - Kafka
    - Technology
tags:
    - 'big data'
    - kafka
    - storm
    - twitter
---

<!-- wp:paragraph -->
<p>Twitter open-sourced its Hosebird client (hbc), a robust Java HTTP library for consuming Twitter’s <a href="https://dev.twitter.com/docs/streaming-apis" target="_blank" rel="noreferrer noopener">Streaming API</a>. In this post, I am going to present a demo of how we can use <em>hbc </em>to create a Kafka twitter stream producer, which tracks a few terms in Twitter statuses and produces a Kafka stream out of it, which can be utilised later for counting the terms, or sending that data from Kafka to Storm (Kafka-Storm pipeline) or HDFS ( as we will see in next post about using Camus API).</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>You can download and run a complete Sample <a href="https://github.com/saurzcode/twitter-stream/" target="_blank" rel="noreferrer noopener">here</a>.</p>
<!-- /wp:paragraph -->

<!-- wp:more -->
<p><!--more--></p>
<!-- /wp:more -->

<!-- wp:heading -->
<h2>Requirements</h2>
<!-- /wp:heading -->

<!-- wp:list -->
<ul>
<li>Apache Kafka 2.6.0</li>
<li>Twitter Developer account ( for API Key, Secret etc.)</li>
<li>Apache Zookeeper ( required for Kafka)</li>
<li>Oracle JDK 1.8 (64 bit )</li>
</ul>
<!-- /wp:list -->

<!-- wp:heading -->
<h2>Build Environment</h2>
<!-- /wp:heading -->

<!-- wp:list -->
<ul>
<li>Eclipse</li>
<li>Apache Maven 2/3</li>
</ul>
<!-- /wp:list -->

<!-- wp:heading -->
<h2>How to Generate Twitter API Keys Using Developer Account</h2>
<!-- /wp:heading -->

<!-- wp:list {"ordered":true} -->
<ol>
<li>Go to <a href="https://dev.twitter.com/apps/new">https://dev.twitter.com/apps/new</a> and log in, if necessary.</li>
<li>Enter your Application Name, Description, and your website address. You can leave the callback URL empty.</li>
<li>Accept the TOS.</li>
<li>Submit the form by clicking the <strong>Create your Twitter Application.</strong></li>
<li>Copy the consumer key (API key) and consumer secret from the screen into your application.</li>
<li>After creating your Twitter Application, you have to give access to your Twitter Account to use this Application. To do this, click the <strong>Create my Access Token.</strong></li>
<li>Now you will have <em>Consumer Key, Consumer Secret, Acess token, Access Token Secret</em> to be used in streaming API calls.</li>
</ol>
<!-- /wp:list -->

<!-- wp:heading -->
<h2>Steps to Run the Sample</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>1. Start the Zookeeper server in Kafka using the following script in your Kafka installation folder  –</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="EnlighterJSRAW" data-enlighter-language="shell">$bin/zookeeper-server-start.sh config/zookeeper.properties &amp;amp;</pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>and, verify if it is running on default port 2181 using –</p>
<!-- /wp:paragraph -->

<!-- wp:code -->
<pre class="wp-block-code"><code>$netstat -anlp | grep 2181</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>2. Start Kafka server using the following script –</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><code>$bin/kafka-server-start.sh config/server.properties  &amp;</code></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>and, verify if it is running on default port 9092</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><em>If you are on a mac, and you have brew installed, both can be done with simple brew commands.</em></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><code>$brew install kafka</code>   # this internally installs zookeeper too</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><code>$brew services start zookeeper</code></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>$kafka-server-start  /usr/local/etc/kafka/server.properties</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>3. Create Topic</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><code>$bin/kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic twitter-topic</code></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>4. Validate the Topic</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><code>$bin/kafka-topics --describe --zookeeper localhost:2181 --topic twitter-topic</code></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>3. Now, when we are all set with Kafka running and ready to accept messages on the topic we just created., we will create a <a href="https://github.com/saurzcode/twitter-stream/blob/master/src/main/java/com/saurzcode/twitter/TwitterKafkaProducer.java" target="_blank" rel="noreferrer noopener">Kafka Producer</a>, which makes use of <em>hbc client API</em> to get twitter stream for tracking terms and puts on the topic named as “<em>twitter-topic</em>”.</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul>
<li>First, we need to give maven dependencies for hbc-core for latest version and some other dependencies needed for Kafka –</li>
</ul>
<!-- /wp:list -->

<!-- wp:preformatted -->
<p class="wp-block-preformatted EnlighterJSRAW" data-enlighter-language="generic"><code>&lt;dependency&gt;</code><br /><code>   &lt;groupId&gt;com.twitter&lt;/groupId&gt;</code><br /><code>   &lt;artifactId&gt;hbc-core&lt;/artifactId&gt; &lt;!-- or hbc-twitter4j --&gt;</code><br /><code>   &lt;version&gt;2.2.0&lt;/version&gt; &lt;!-- or whatever the latest version is --&gt;</code><br /><code>&lt;/dependency&gt;</code><br /><code>&lt;dependency&gt;</code><br /><code>   &lt;groupId&gt;org.apache.kafka&lt;/groupId&gt;</code><br /><code>   &lt;artifactId&gt;kafka-clients&lt;/artifactId&gt;</code><br /><code>   &lt;version&gt;2.6.0&lt;/version&gt;</code><br /><code>&lt;/dependency&gt;</code></p>
<!-- /wp:preformatted -->

<!-- wp:list -->
<ul>
<li> Then, we need to set properties to configure our Kafka Producer to publish messages to the topic –</li>
</ul>
<!-- /wp:list -->

<!-- wp:code -->
<pre class="wp-block-code"><code>Properties properties = new Properties();
properties.put(ProducerConfig.&lt;em&gt;BOOTSTRAP_SERVERS_CONFIG&lt;/em&gt;, TwitterKafkaConfig.&lt;em&gt;SERVERS&lt;/em&gt;);
properties.put(ProducerConfig.&lt;em&gt;ACKS_CONFIG&lt;/em&gt;, "1");
properties.put(ProducerConfig.&lt;em&gt;LINGER_MS_CONFIG&lt;/em&gt;, 500);
properties.put(ProducerConfig.&lt;em&gt;RETRIES_CONFIG&lt;/em&gt;, 0);
properties.put(ProducerConfig.&lt;em&gt;KEY_SERIALIZER_CLASS_CONFIG&lt;/em&gt;, LongSerializer.class.getName());
properties.put(ProducerConfig.&lt;em&gt;VALUE_SERIALIZER_CLASS_CONFIG&lt;/em&gt;, StringSerializer.class.getName());</code></pre>
<!-- /wp:code -->

<!-- wp:list -->
<ul>
<li>Set up a <em>StatusFilterEndpoint</em>, which will set up track terms to be tracked on recent status messages, as in the example - <br /><br />StatusesFilterEndpoint endpoint = new StatusesFilterEndpoint();</li>
<li>endpoint.trackTerms(Lists.newArrayList(term));</li>
<li>Provide authentication parameters for OAuth ( we are getting them using command line parameters for this program, so don't forget to pass those as VM arguments when you run it on IDE) for using twitter that we generated earlier and create the client using endpoint and auth –</li>
</ul>
<!-- /wp:list -->

<!-- wp:code -->
<pre class="wp-block-code"><code>Authentication auth = new OAuth1(consumerKey, consumerSecret, token,
        secret);

Client client = new ClientBuilder().hosts(Constants.&lt;em&gt;STREAM_HOST&lt;/em&gt;)
        .endpoint(endpoint).authentication(auth)
        .processor(new StringDelimitedProcessor(queue)).build();</code></pre>
<!-- /wp:code -->

<!-- wp:list -->
<ul>
<li>Last step, connect to the client, fetch messages from the queue and send through Kafka Producer –</li>
</ul>
<!-- /wp:list -->

<!-- wp:code -->
<pre class="wp-block-code"><code>client.connect();
try (Producer&amp;lt;Long, String&gt; producer = &lt;em&gt;getProducer&lt;/em&gt;()) {
while (true) {
ProducerRecord&amp;lt;Long, String&gt; message = new ProducerRecord&amp;lt;&gt;(TwitterKafkaConfig.&lt;em&gt;TOPIC&lt;/em&gt;, queue.take());
producer.send(message);
}
} catch (InterruptedException e) {
e.printStackTrace();
} finally {
client.stop();
}</code></pre>
<!-- /wp:code -->

<!-- wp:paragraph -->
<p>To run the complete example run <a href="https://github.com/saurzcode/twitter-stream/blob/master/src/main/java/com/saurzcode/twitter/TwitterKafkaProducer.java">TwitterKafkaProducer.java </a>class as a Java Application in your favorite IDE and don't forget to pass the arguments with your API keys and terms. Read detailed instructions <a href="https://github.com/saurzcode/twitter-stream/blob/master/README.md" target="_blank" rel="noreferrer noopener">here</a>.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Also, to see how you can integrate Kafka with HDFS using camus from LinkedIn, you can visit the blog <a href="http://saurzcode.in/2015/02/integrate-kafka-hdfs-using-camus-twitter-stream-example/">here</a>.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Happy Learning !!</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>References:-</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>[1] https://kafka.apache.org/quickstart.html</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>[2] https://github.com/twitter/hbc</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>[3] https://themepacific.com/how-to-generate-api-key-consumer-token-access-key-for-twitter-oauth/994/</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Interesting Reads -</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><a href="https://wp.me/p5pWDa-iX">Multithreaded Mappers in Mapreduce</a></p>
<!-- /wp:paragraph -->