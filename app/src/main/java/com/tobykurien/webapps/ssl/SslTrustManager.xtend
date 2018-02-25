package com.tobykurien.webapps.ssl

import com.tobykurien.webapps.data.Webapp
import java.security.cert.CertificateException
import java.security.cert.X509Certificate
import javax.net.ssl.X509TrustManager

class SslTrustManager implements X509TrustManager {
	var Webapp webapp
	
	public new(Webapp webapp) {
		this.webapp = webapp
	}

	override checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
	}
	
	override checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
		// TODO - verify SSL certificate against webapp's saved certificate details
	}
	
	override getAcceptedIssuers() {
	}	
}
