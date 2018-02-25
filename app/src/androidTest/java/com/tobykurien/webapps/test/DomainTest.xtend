package com.tobykurien.webapps.test

import com.tobykurien.webapps.webviewclient.WebClient
import org.junit.Test

import static org.junit.Assert.*

// Test the critital domain handling code
class DomainTest {
    @Test
    def void testGetHost() {
        assertEquals(WebClient.getHost("tobykurien.com"), "tobykurien.com")
        assertEquals(WebClient.getHost("tobykurien.com/something"), "tobykurien.com")
        assertEquals(WebClient.getHost("http://tobykurien.com/something"), "tobykurien.com")
        assertEquals(WebClient.getHost("https://tobykurien.com:8080/something"), "tobykurien.com")
    }
}
