package com.tobykurien.webapps.fragment

import android.net.http.SslCertificate
import com.tobykurien.webapps.data.Webapp
import org.xtendroid.annotations.AndroidDialogFragment
import com.tobykurien.webapps.R
import org.xtendroid.app.OnCreate
import android.os.Bundle

@AndroidDialogFragment(R.layout.dlg_certificate_changed) class DlgCertificateChanged extends DlgCertificate {
    var Webapp webapp = null

    public new(Webapp webapp, SslCertificate certificate, String title, String okText,
        ()=>boolean onOkClicked, ()=>boolean onCancelClicked) {
        super(certificate, title, okText, onOkClicked, onCancelClicked)
        this.webapp = webapp
    }

    @OnCreate
    override init() {
        issuedBy1.text = webapp.certIssuedBy.formatDname
        issuedTo1.text = webapp.certIssuedTo.formatDname
        expires1.text = webapp.certValidFrom + " to \n" + webapp.certValidTo

        issuedBy2.text = certificate.issuedBy.DName.formatDname
        issuedTo2.text = certificate.issuedTo.DName.formatDname
        expires2.text = certificate.validNotBeforeDate.toLocaleString + " to \n" +
                certificate.validNotAfterDate.toLocaleString
    }

}