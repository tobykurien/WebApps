package com.tobykurien.webapps.fragment

import android.net.http.SslCertificate
import com.tobykurien.webapps.data.Webapp
import org.xtendroid.annotations.AndroidDialogFragment
import com.tobykurien.webapps.R
import org.xtendroid.app.OnCreate
import android.os.Bundle
import android.support.v7.app.AlertDialog

@AndroidDialogFragment(R.layout.dlg_certificate_changed) class DlgCertificateChanged extends DlgCertificate {
    var Webapp webapp = null
	var protected ()=>boolean onIgnoreClicked = null

    public new(Webapp webapp, SslCertificate certificate, String title, String okText,
        ()=>boolean onOkClicked, ()=>boolean onCancelClicked, ()=>boolean onIgnoreClicked) {
        super(certificate, title, okText, onOkClicked, onCancelClicked)
        this.webapp = webapp
        this.onIgnoreClicked = onIgnoreClicked
    }

    /**
     * Create a dialog using the AlertDialog Builder, but our custom layout
     */
    override onCreateDialog(Bundle instance) {
        if (title == null) title = getString(R.string.title_certificate)

        new AlertDialog.Builder(activity)
            .setTitle(title)
            .setView(contentView) // contentView is the layout specified in the annotation
            .setPositiveButton(
                if (okText == null) getString(android.R.string.ok) else okText, [ 
                    if (onOkClicked != null) onOkClicked.apply() 
                ]) // to avoid it closing dialog
            .setNegativeButton(android.R.string.cancel, [
                if (onCancelClicked != null) onCancelClicked.apply()
            ])
            .setNeutralButton(R.string.btn_disable_cert_checks, [
                if (onIgnoreClicked != null) onIgnoreClicked.apply()
            ])
            .create()
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