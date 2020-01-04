package com.tobykurien.webapps.test

import com.tobykurien.webapps.webviewclient.WebClient
import org.junit.Test

import static org.junit.Assert.*
import android.net.Uri

// Test the critital domain handling code
class DomainTest {
    @Test
    def void testGetHost() {
        assertEquals(WebClient.getHost("tobykurien.com"), "tobykurien.com")
        assertEquals(WebClient.getHost("tobykurien.com/something"), "tobykurien.com")
        assertEquals(WebClient.getHost("http://tobykurien.com/something"), "tobykurien.com")
        assertEquals(WebClient.getHost("https://tobykurien.com:8080/something"), "tobykurien.com")
    }

    @Test
    def void testRootDomain() {
        assertEquals(WebClient.getRootDomain("www.tobykurien.com"), "tobykurien.com")
        assertEquals(WebClient.getRootDomain("www.tobykurien.co.za"), "tobykurien.co.za")
        assertEquals(WebClient.getRootDomain("www.tobykurien.org.za"), "tobykurien.org.za")
        assertEquals(WebClient.getRootDomain("fast.ai"), "fast.ai")
        assertEquals(WebClient.getRootDomain("www.fast.ai"), "fast.ai")
    }

    @Test
    def void testIsInSandbox() {
        var domainUrls = #[ "tobykurien.com", "tobykurien.co.za", "tobykurien.org.za" ].toSet
        assertTrue(WebClient.isInSandbox(Uri.parse("https://cloud.tobykurien.com"), domainUrls))
        assertTrue(WebClient.isInSandbox(Uri.parse("https://www.tobykurien.co.za"), domainUrls))
        assertTrue(WebClient.isInSandbox(Uri.parse("https://www.tobykurien.org.za"), domainUrls))
        assertFalse(WebClient.isInSandbox(Uri.parse("https://www.test.co.za"), domainUrls))
        assertFalse(WebClient.isInSandbox(Uri.parse("https://www.test.org.za"), domainUrls))
    }
}
