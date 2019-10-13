package com.tobykurien.webapps.utils

import android.net.http.SslCertificate
import com.tobykurien.webapps.data.Webapp
import com.tobykurien.webapps.db.DbService
import java.io.UnsupportedEncodingException
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class CertificateUtils {
    def static String SHA1(String text) throws NoSuchAlgorithmException, UnsupportedEncodingException {
        var md = MessageDigest.getInstance("SHA-1");
        var textBytes = text.getBytes("iso-8859-1");
        md.update(textBytes, 0, textBytes.length);
        var sha1hash = md.digest();
        return sha1hash.map[ Integer.toHexString(it) ].join();
    }	
	
	// Create a hash of the certificate for comparison
	def static String certificateHash(SslCertificate certificate) {
		SHA1(certificate.issuedBy.DName) // + certificate.issuedTo.DName)
	}
	
	// Create a hash of the webapp's saved certificate details for comparison
	def static String certificateHash(Webapp webapp) {
		SHA1(webapp.certIssuedBy) // + webapp.certIssuedTo)
	}
		
	def static int compare(SslCertificate cert1, SslCertificate cert2) {
		cert1.certificateHash.compareTo(cert2.certificateHash)
	}

	def static int compare(Webapp webapp, SslCertificate cert2) {
		webapp.certificateHash.compareTo(cert2.certificateHash)
	}

	// Save the certificate details to the webapp	
	def static void updateCertificate(Webapp webapp, SslCertificate certificate, DbService db) {
		if (certificate === null || certificate.issuedBy === null ||
			certificate.issuedTo === null) return;
		
		db.update(DbService.TABLE_WEBAPPS, #{
			'certIssuedBy' -> certificate.issuedBy.DName,
			'certIssuedTo' -> certificate.issuedTo.DName,
			'certValidFrom' -> certificate.validNotBefore,
			'certValidTo' -> certificate.validNotAfter
		}, webapp.id)				
	}

	def static boolean canBeUnencrypted(String url){
		// Domains would also need to be excempted from HTTPS in res/xml/network_security_config.xml if useCleartextTraffic wasn't enabled
		return
			url.matches("(?i)^(https?:\\/\\/)?localhost($|\\/.*|:\\d+.*)") ||      // localhost
			url.matches("(?i)^(https?:\\/\\/)?127.0.0.1($|\\/.*|:\\d+.*)") ||      // IPv4 loopback
			url.matches("(?i)^(https?:\\/\\/)?::1($|\\/.*|:\\d+.*)") ||            // IPv6 loopback
			url.matches("(?i)^(https?:\\/\\/)?10(\\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}($|\\/.*|:\\d+.*)") || // Class A private network (10.0.0.0 to 10.255.255.255)
			url.matches("(?i)^(https?:\\/\\/)?172\\.(1[6-9]|2[0-9]|3[0-1])(\\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){2}($|\\/.*|:\\d+.*)") || // Class B private network (172.16.0.0 to 172.31.255.255)
			url.matches("(?i)^(https?:\\/\\/)?192\\.168(\\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){2}($|\\/.*|:\\d+.*)") // Class C private network (192.168.0.0 to 192.168.255.255)
	}
}